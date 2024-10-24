class BuffObserver {
    __New(coords){
        this.coords := coords
        this.buff_first := [1500,90] 
        this.buff_next := 90
        this.buff_count := 10
        this.buff_timer_offset := [-13,60]
        this.c_buff_stormseye := 0xCC4A19
        this.c_buff_inner_release := 0xED351B
        this.c_buff_nascent_chaos := 0x593311
        this.c_buff_timer :=[0x89C9A3,0xB5EED0,0x71B58B,0xB3EDCE,0xADE7C7] ; [1min,5x,4x,3x,2X]

    }
    update(ps){
        x := this.buff_first[1]
        y := this.buff_first[2]

        tasks := []
        buffs := []

        for k,v in this.coords {
            tasks.push([k,v])
        }

        Loop, % this.buff_count {
            c := pixGet(x,y,ps)

            index := 1
            while index <= tasks.Length() {
                task := tasks[index]
                key := task[1]
                matcher := task[2]
        
                if (!pixMatch(c,matcher)) {
                    buffs[key] := 0
                    index += 1
                    continue
                }
                buffs[key] := 1
                tx := x + this.buff_timer_offset[1]
                ty := y + this.buff_timer_offset[2]
                tc := pixGet(tx,ty,ps)
                for k,v in this.c_buff_timer {
                    if (pixMatch(tc,v)){
                        buffs[key] := 7 - k
                        break
                    }
                }
                tasks.RemoveAt(index)
            }
            if (tasks.Length == 0){
                break
            }
            x += this.buff_next
        }  
        this.buffs := buffs
    }
    get(key){
        return this.buffs[key]
    }
}