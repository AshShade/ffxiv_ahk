class Strategy{
    cast(s){
        if (s["mooch2"] == "active"){
            return "3"
        }
        if (s["mooch"]){
            return "2"
        }


        if (s["gp"] == "empty" && s["cordial"]){
            return "b"
        }

        if (s["mooch2"] != "ready" && !s["buff_patience"]){
            if (s["gp"] == "lack" && s["cordial"]){
                return "b"
            } else if (s["patience2"]){
                return "x"
            }
        }

        if (s["gp"] == "full"){
            return "c"
        }
        return "1"
    }

    hook(s){
        if (!s["tug"]){
            if (s["last_cast"] == "1" &&  (A_TickCount - s["last_cast_t"] > 15000)){
                return "f"
            }
            return 0
        }
        if (s["buff_patience"]){
            if (s["tug"] == 1){
                return "q"
            }
            return "e"
        }
        return "f"
    }

    
}