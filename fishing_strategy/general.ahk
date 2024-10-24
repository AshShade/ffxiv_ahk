class Strategy{
    cast(s){
        if (!s["buff_patience"]){
            if (s["patience2"]){
                return "r"
            } else {
                if (s["favor"]){
                    return "t"
                } 
                if (s["cordial"]) {
                    return "``"
                }
            }
        }
        return "1"
    }
    hook(s){
        if (!s["tug"]){
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