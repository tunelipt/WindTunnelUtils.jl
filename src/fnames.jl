export numstring


"""
`numstring(n, d)`

Create a string containing an integer with `d` digits preceded by `0` if the number
`n` is less than `10^d`.

Useful for creating file names that are listed in numerical order.

"""
numstring(n::Integer, d=3) = string(10^d+n)[2:end]
