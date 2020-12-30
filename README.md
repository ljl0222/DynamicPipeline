# 动态流水线的实现

1851977 李家麟

## 简单的思路介绍

将整个动态流水线的过程分为IF，ID，EXE，MEM，WB五个流水阶段，每个阶段传递数据。

## 简单的要点介绍

### 流水暂停

这里我们的动态流水线实际上是不保留流水暂停的，基本上不需要暂停的情况。

在流水暂停阶段，我们控制stall信号暂停即可。

### 数据前推

当后面的流水阶段使用了前面指令未执行到的阶段的数据的时候，需要数据前推。

考虑连续执行的四条指令：指令1~指令4

- 指令4的id阶段需要指令3的exe阶段的数据
- 指令4的id阶段需要指令2的mem阶段的数据
- 指令4的id阶段需要指令1的wb阶段的数据

因此这里，我们就需要建立起从exe，mem，wb阶段前推到id阶段的通道。

### 简单的错误提醒

这里，请大家看看我编写的cpuBus中的各个流水寄存器赋值的阶段，如果我在这里编写的时候没有记错的话，我应当是采用了这样子的编写方式：

```verilog
    // IF/ID reg
    always @ (posedge clk or posedge rst)
    begin
        if(rst || (stall[0] & !stall[1]))
        begin
            ifid_npc <= 32'h0;
            ifid_instr <= 32'h0; 
        end
        else if(!stall[0])
        begin
            ifid_npc <= if_npc;
            ifid_instr <= if_imem_instr;
        end
    end
    // ID/EXE reg
    ...
```

请注意，如果这里下板的时候出现了一定的问题，尤其是传出28号寄存器（最终其结果正确的话，应当是0xa0602880）值一直为8个0的情况的话...

首先，我建议大家将pc值传出来，将cpu频率分至极低，从而可以看到自己pc值的实时变化。当然，这里说的pc值传出来，是指传到数码管上，下板显示，simulate不会有人过不了吧。

然后这里呢，如果发现pc值在遇到第一个暂停的时候停下不再移动（没错，这里说的是静态流水线，我们动态流水线是不存在暂停的，如果动态流水线下板出现了问题，也欢迎大家和我讨论）。

这里大家可以尝试一个玄学的修改，将上述的代码修改为如下的样子：

```verilog
    // IF/ID reg
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
        begin
            ifid_npc <= 32'h0;
            ifid_instr <= 32'h0; 
        end
        else if(stall[0] & !stall[1])
        begin
            ifid_npc <= 32'h0;
            ifid_instr <= 32'h0; 
        end
        else if(!stall[0])
        begin
            ifid_npc <= if_npc;
            ifid_instr <= if_imem_instr;
        end
    end
    // ID/EXE reg
    ...
```

虽然不知道为什么，但是我的室友确实是这样修改就能成功下板静态流水线了，也许这就是神奇的硬件语言，神奇的静态流水线吧。当然，我自己在动态流水线的下板过程中没有遇到这样的玄学问题。

另外这里给出一个不负责任的猜测，我估计这样修改没准也行：

```verilog
    // IF/ID reg
    always @ (posedge clk or posedge rst)
    begin
        if((stall[0] & !stall[1]) || rst)
        begin
            ifid_npc <= 32'h0;
            ifid_instr <= 32'h0; 
        end
        else if(!stall[0])
        begin
            ifid_npc <= if_npc;
            ifid_instr <= if_imem_instr;
        end
    end
    // ID/EXE reg
    ...
```

哈哈，真神奇啊x。

总之，虽然他是个玄学问题，但是我们多加思索，通过一点点的排查分析，将不同的测试信号输出，也是可以得到正确的结果的，希望大家都能运气好一点。