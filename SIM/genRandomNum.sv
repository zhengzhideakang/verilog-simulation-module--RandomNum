/*
 * @Author       : Xu Xiaokang
 * @Email        :
 * @Date         : 2025-04-25 20:39:36
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2025-04-28 01:09:33
 * @Filename     :
 * @Description  :
*/

/*
! 模块功能: 用于在仿真中产生真随机数
* 思路:
  1.
*/

module genRandomNum ();

//++ 仿真时间尺度 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
timeunit 1ns;
timeprecision 1ps;
//-- 仿真时间尺度 ------------------------------------------------------------


//++ 随机种子 与 种子数组 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
* 通过调用C语言函数获取系统时间作为种子,
* 重启仿真种子会变化
*/
import "DPI-C" function longint get_system_time();
longint timestamp_us;
int timestamp_seed;
event timestamp_seed_ready;
initial begin
  timestamp_us = get_system_time();
  $display("timestamp_us = ", timestamp_us);
  timestamp_seed = int'(timestamp_us ^ (timestamp_us >> 32)); // 高低位异或
  $display("timestamp_seed = ", timestamp_seed);
  $display("timestamp_seed initial success!!!!!!!!!!");
  -> timestamp_seed_ready;
end

/*
* 通过外部TCL命令获取系统时间，再传递给SEED参数作为种子
* 需关闭仿真再启动仿真种子才会变化，重启仿真种子不变
*/
// parameter int SEED = 0;
// initial begin
//   timestamp_seed = SEED;
//   $display("the timestamp_seed is %d", timestamp_seed);
//   $display("timestamp_seed initial success!!!!!!!!!!");
//   -> timestamp_seed_ready;
// end

int seeds [20];
event seeds_ready;
initial begin
  wait(timestamp_seed_ready.triggered); //* 等待系统时间种子初始化完成
  $srandom(timestamp_seed);
  foreach (seeds[i]) begin
    seeds[i] = $urandom();  //* 使用 $urandom() 初始化 seeds 数组
  end
  for (int i=0; i<20; i++) begin
    $display("seeds[%0d] = 0x%08x", i, seeds[i]);
  end
  $display("seeds initial success!!!!!!!!!!");
  -> seeds_ready; //* 种子数组初始化完成
end
//-- 随机种子 与 种子数组 ------------------------------------------------------------


//++ 生成随机数 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int unsigned num1;
initial begin
  wait(seeds_ready.triggered); //* 等待种子数组初始化完成
  $srandom(seeds[0]); //* 指定此initial线程的初始种子
  repeat(100) begin
    num1 = $urandom_range(0, 2**31-1);
    $display("num1 = ", num1);
    #1;
  end
  $stop;
end
//-- 生成随机数 ------------------------------------------------------------


endmodule