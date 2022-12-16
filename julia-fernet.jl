using Conda
Conda.add("cryptography", :py_crypto_env)
Conda.PYTHONDIR
ENV["PYTHON"] = "/home/kon/.julia/conda/3/envs/py_crypto_env/bin/python"
using Pkg
Pkg.build("PyCall")
using PyCall

py"""
from cryptography.fernet import Fernet
key = Fernet.generate_key()
f = Fernet(key)
"""

txt = "A really 秘密 message. Not for prying eyes."

py"""
encrypted = f.encrypt(bytes($txt, 'utf-8'))
print(encrypted)
"""
py"""
decrypted = f.decrypt(encrypted)
print(decrypted)
"""

encrypted = py"f.encrypt(bytes($txt, 'utf-8'))"

function encrypt(txt::String)
    return py"f.encrypt(bytes($txt, 'utf-8'))"
end

function encrypt(txts::Vector{String})
    return py"[f.encrypt(bytes(txt, 'utf-8')) for txt in $txts]"
end

encrypted = encrypt(txt)

function decrypt(token::String)
    return py"f.decrypt($token)"
end

function decrypt(tokens::Vector{String})
    return py"[f.decrypt(tok) for tok in $tokens]"
end

decrypt(encrypted)

encrypts = [py"f.encrypt(bytes($txt, 'utf-8'))" for _ in 1:1000]

decrypt.(encrypts)

using Random

n_sample = 1*10^5
txts = [randstring("吾輩は猫である。名前はまだない。", 5) for _ in 1:n_sample]
@time encrypts = encrypt.(txts);
@time encrypts = encrypt(txts);

@time decrypt.(encrypts);
@time decrypt(encrypts);
