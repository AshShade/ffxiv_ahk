class ComboObserver{
    __New(conds){
        this.conds := conds 
        this.state := [0,0]
    }

    start(){
        this.observing := true
        this.current :=  [0,0]
    }
    end(){
        this.observing := false
        if (this.current[1] != this.state[1]){
            this.state := this.current
        }
    }
    get(){
        if (this.state[1]){
            return [this.state[1], A_TickCount - this.state[2] > 12000]
        }
        return [0,false]
    }
    observe(){
        if (this.observing){
            for k,v in this.conds {
                if (v.get()){
                    if (this.current[1] != k){
                        this.current := [k,A_TickCount]
                        break
                    }
                }
            }
        }
        if (A_TickCount - this.state[2] > 15000){
            this.state := [0,0]
        }
    }
}
