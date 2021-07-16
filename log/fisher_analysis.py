def main():
    filename = "fisher.log"
    stats = {}
    with open(filename,"r") as f:
        for line in f:
            cols = line.strip().split()
            record = stats.get(cols[0],[None,None,None,None])
            min_i = 0
            max_i = 1
            if (len(cols) == 3):
                min_i = 2
                max_i = 3

            time = float(cols[1])
            if not record[min_i] or time < record[min_i]:
                record[min_i] = time

            if not record[max_i] or time > record[max_i]:
                record[max_i] = time

            stats[cols[0]] = record
        

        for key in stats:
            print("{}: [{} , {}] | 撒饵后: [{} , {}]".format(key,stats[key][0],stats[key][1],stats[key][2],stats[key][3]))
main()