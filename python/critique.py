def transpose(matrix):
    return tuple(tuple(i) for i in zip(*matrix))

print(transpose(((0,1,0), (0,1,0), (0,0,1))))
