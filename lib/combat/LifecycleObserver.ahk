; Job Object
;     Properties:
;           gcd_window
;           gcd_coord
;           gcd_idle
;           gcd_busy
;     Methods:
;           onCombatEnd
;           onStateChange
class LifecycleObserver {
    __New(job){
        this.job := job
        this.t_end := (job.gcd_window - 0.8) * 1000
        this.t_mid := this.t_end / 2 
        this.t_stamp := 0
        this.state := 1
        this.series := 1
    }

    observe(){
        gcd := pixGet(this.job.gcd_coord*)
        if (pixMatch(gcd,this.job.gcd_idle)){
            new_state := 1
        } else {
            if (pixMatch(gcd, this.job.gcd_busy)){
                if (!this.flag){
                    this.flag := true
                    if (A_TickCount - this.t_stamp > 10000) {
                        this.job.onCombatEnd()
                    }
                    this.t_stamp := A_TickCount
                }
            } else {
                this.flag := false
            }
            tick := A_TickCount - this.t_stamp

            if (tick > this.t_end){
                new_state := 4
            } else if (tick > this.t_mid){
                new_state := 3
            } else {
                new_state := 2
            }
        }

        if (new_state != this.state){
            this.state := new_state
            if (this.state == 4){
                this.series += 1
            }
            this.job.onStateChange(new_state)
        }

    }

    getTick(){
        return A_TickCount - this.t_stamp
    }

    ; 1 => GCD START, 2 => OGCD1, 3 => OGCD2, 4 => GCD END
    get(){
        return [this.state, this.series]
    }
}
