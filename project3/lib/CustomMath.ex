defmodule CustomMath do
    def sqrt(num) do
        rtn = 0;
        if num > 0 do
            rtn = getsqrt(1, num)
        end
        rtn
    end

    def getsqrt(index, num) do
        if index * index <= num do
            getsqrt(index + 1, num)
        else
            index - 1
        end
    end
end