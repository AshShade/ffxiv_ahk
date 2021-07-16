class ComboChecker {
    __New(coords){
        this.coords := coords 
        this.state := [0,0]
        this.is_active := new PixRGBMatcher({r_min : 180, b_max : 80})
    }

    check(ps) {
        ; pixScreenSave("screencuts/" A_Now ".png",ps)
        for k,v in this.coords {
            x := v[1]
            y := v[2]
            if (pixMatch(pixGet(x,y,ps),this.is_active) || pixMatch(pixGet(x - 5,y,ps),this.is_active)  || pixMatch(pixGet(x + 5,y,ps),this.is_active) ){
                this.update(k)
                return
            }
        }
        this.update(0)
    }

    update(val){
        if (this.state[1] != val){
            this.state := [val,A_TickCount]
        }
    }

    get() {
        if (this.state[1] > 0){
            t :=  A_TickCount - this.state[2]
            if (t < 13000){
                return [this.state[1], t]
            } else {
                this.state := [0,0]
            }
        }
        return [0,0]
    }
}