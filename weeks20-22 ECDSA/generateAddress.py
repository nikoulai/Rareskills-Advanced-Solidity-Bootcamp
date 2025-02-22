from ecpy.curves import Curve
from Crypto.Hash import keccak
import secrets

eth_addr = '0x'

# private_key = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
while eth_addr.split('x')[1][0:4] != '0000':
	private_key = secrets.randbits(256)

	k = keccak.new(digest_bits=256)

	cv     = Curve.get_curve('secp256k1')
	pu_key = private_key * cv.generator # just multiplying the private key by generator point (EC multiplication)

	concat_x_y = pu_key.x.to_bytes(32, byteorder='big') + pu_key.y.to_bytes(32, byteorder='big')
	eth_addr = '0x' + k.update(concat_x_y).hexdigest()[-40:]

print('private key: ', hex(private_key))
print('eth_address: ', eth_addr)

# private key:  0x64c518bdb3a04bd940228f6d1ff1688b4c55584f2abcc1e8a6d99eeabc2216de
# eth_address:  0x0000f466e0a377e82f1bcf4e2aed5064f1894351


