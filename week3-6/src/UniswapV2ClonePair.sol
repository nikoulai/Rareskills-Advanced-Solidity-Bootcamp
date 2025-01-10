// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {ERC20} from "solady/tokens/ERC20.sol";
import "solady/utils/FixedPointMathLib.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import {IERC3156FlashLender, IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";

import "./libraries/UQ112x112.sol";

// _swap line 176: the computation for pair doesnt use the sorted token0
//( token1 doesnt exist), why they use input, output?
// contract UniswapV2ClonePair is ReentrancyGuard, ERC20 {
contract UniswapV2ClonePair is IUniswapV2Pair, ERC20, ReentrancyGuard, IERC3156FlashLender {
    using UQ112x112 for uint224;

    address public token0;
    address public token1;

    address public immutable factory;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast;

    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    modifier validToken(address token) {
        require(token == token0 || token == token1, "UniswapV2Clone: INVALID TOKEN");
        _;
    }

    constructor() ERC20() {
        factory = msg.sender;
    }

    function name() public pure virtual override(ERC20) returns (string memory) {
        return "Uniswap V2 CLONE";
    }

    function symbol() public pure virtual override(ERC20) returns (string memory) {
        return "UNI-V2-CLONE";
    }

    function safeMint(
        address to,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) external nonReentrant returns (uint256 liquidity) {
        uint256 amountA;
        uint256 amountB;
        (uint256 reserveA, uint256 reserveB,) = getReserves();
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "UniswapV2Router: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "UniswapV2Router: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
        ERC20(token0).transferFrom(msg.sender, address(this), amountA);
        ERC20(token1).transferFrom(msg.sender, address(this), amountB);
        liquidity = this.mint(to);
    }

    function mint(address to) external returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint256 balance0 = ERC20(token0).balanceOf(address(this));
        uint256 balance1 = ERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            liquidity = FixedPointMathLib.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity =
                FixedPointMathLib.min((amount0 * _totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
        }
        require(liquidity > 0, "UniswapV2Clone: INSUFFICIENT_LIQUIDITY");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * uint256(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    function safeBurn(address to, uint256 liquidity, uint256 amountAMin, uint256 amountBMin)
        external
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
        /// @dev send liquidity to pair
        ERC20(address(this)).transferFrom(msg.sender, address(this), liquidity);
        (amount0, amount1) = this.burn(to);
        require(amount0 >= amountAMin, "UniswapV2Clone: INSUFFICIENT_A_AMOUNT");
        require(amount1 >= amountBMin, "UniswapV2Clone: INSUFFICIENT_B_AMOUNT");
    }

    function burn(address to) external returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = ERC20(_token0).balanceOf(address(this));
        uint256 balance1 = ERC20(_token1).balanceOf(address(this));
        uint256 _totalSupply = totalSupply();

        bool feeOn = _mintFee(_reserve0, _reserve1);

        uint256 liquidity = balanceOf(address(this));
        // the protocol here uses
        // uint256 balance0 = ERC20(token0).balanceOf(address(this));
        //instead of reserve0, why? by using balance it can send more than reserve
        amount0 = liquidity * _reserve0 / _totalSupply;
        amount1 = liquidity * _reserve1 / _totalSupply;

        _burn(address(this), liquidity);

        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);

        balance0 = ERC20(_token0).balanceOf(address(this));
        balance1 = ERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * uint256(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "UniswapV2Clone: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "UniswapV2Clone: INSUFFICIENT_LIQUIDITY");

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2Clone: INVALID_TO");
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            balance0 = ERC20(_token0).balanceOf(address(this));
            balance1 = ERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        // K invariant is not enough?
        require(amount0In > 0 || amount1In > 0, "UniswapV2Clone: INSUFFICIENT_INPUT_AMOUNT");
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted = balance0 * 1000 - amount0In * 3;
            uint256 balance1Adjusted = balance1 * 1000 - amount1In * 3;
            require(
                balance0Adjusted * balance1Adjusted >= uint256(_reserve0) * uint256(_reserve1) * (1000 ** 2),
                "UniswapV2Clone: K"
            );
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
    // force balances to match reserves

    function skim(address to) external nonReentrant {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, ERC20(_token0).balanceOf(address(this)) - reserve0);
        _safeTransfer(_token1, to, ERC20(_token1).balanceOf(address(this)) - reserve1);
    }

    function sync() external nonReentrant {
        _update(ERC20(token0).balanceOf(address(this)), ERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2Clone: RESTRICTED");

        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function flashLoan(IERC3156FlashBorrower _receiver, address _token, uint256 _amount, bytes calldata _data)
        external
        validToken(_token)
        returns (bool)
    {
        uint256 fee = this.flashFee(_token, _amount);

        require(ERC20(_token).transfer(address(_receiver), _amount), "UniswapV2Cloce: FlashLender: TransferFailed");
        require(
            _receiver.onFlashLoan(msg.sender, _token, _amount, fee, _data)
                == keccak256("ERC3156FlashBorrower.onFlashLoan"),
            "UniswapV2Cloce: FlashLender: Callback failed"
        );
        require(
            ERC20(_token).transferFrom(address(_receiver), address(this), _amount + fee),
            "UniswapV2Cloce: FlashLender: PaybackFailed"
        );
        return true;
    }

    function flashFee(address _token, uint256 _amount) external view validToken(_token) returns (uint256) {
        return _amount * 3 / 1000;
    }

    function maxFlashLoan(address _token) external view validToken(_token) returns (uint256) {
        return ERC20(_token).balanceOf(address(this));
    }

    //internal for testing
    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) internal virtual {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, "UniswapV2Clone: OVERFLOW");
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed;
        unchecked {
            timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        }
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    //Uniswap V2’s _safeTransfer is subject to the memory expansion attack (very unlikely, but still should be guarded against). Since only one bool will be read, it’s best to returndatacopy only one word.
    // Try to avoid getting into the habit of reading the entire return data from other contracts.
    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        // bytes[2] memory datacopy;
        // datacopy = bytes[0];
        // datacopy = bytes[1];
        require(success && (data.length == 0 || abi.decode(data, (bool))), "UniswapV2Clone: TRANSFER_FAILED");
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = FixedPointMathLib.sqrt(uint256(_reserve0) * uint256(_reserve1));
                uint256 rootKLast = FixedPointMathLib.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * (rootK - rootKLast);
                    uint256 denominator = rootK * 5 + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Clone: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Clone: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }
}
