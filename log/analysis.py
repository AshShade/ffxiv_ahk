def main():
    analysis("normal.txt")
    analysis("active.txt")


def analysis(filename):
    print("analysis",filename)
    with open(filename,"r") as f:
        ranges = [[500,-500] for _ in range(3)]
        for line in f:
            color = line.strip()
            for i in range(3):
                c = int(color[i*2:i*2+2],16)
                if c < ranges[i][0]:
                    ranges[i][0] = c
                if c > ranges[i][1]:
                    ranges[i][1] = c
    colors = ["red","green","blue"]
    for i in range(3):
        print("{} range => [{},{}]".format(colors[i],ranges[i][0],ranges[i][1]),end="  ")
    print("\n")
main()
