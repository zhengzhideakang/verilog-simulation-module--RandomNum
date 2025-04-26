/*
 * @Author       : Xu Xiaokang
 * @Email        :
 * @Date         : 2025-04-25 20:39:36
 * @LastEditors  : Xu Xiaokang
 * @LastEditTime : 2025-04-26 22:15:32
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


//++ 随机种子 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
* 通过调用C语言函数获取系统时间作为种子,
* 重启仿真种子会变化
*/
import "DPI-C" function longint get_system_time();
longint timestamp_us;
int seed;
initial begin
  timestamp_us = get_system_time();
  $display("timestamp_us = ", timestamp_us);
  seed = int'(timestamp_us ^ (timestamp_us >> 32)); // 高低位异或
  $display("seed = ", seed);
  $srandom(seed); //* 指定全局种子
end
//-- 随机种子 ------------------------------------------------------------
/*
* 通过外部TCL命令获取系统时间，再传递给SEED参数作为种子
* 需关闭仿真再启动仿真种子才会变化，重启仿真种子不变
*/
// parameter int SEED = 0;
// initial begin
//   $srandom(SEED); //* 指定全局种子
//   $display("the SEED is %d", SEED);
// end
//-- 随机种子 ------------------------------------------------------------


//++ 生成随机数 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int unsigned num1;
initial begin
  repeat(10) begin
    num1 = $urandom_range(0, 2**31);
    $display("num1 = ", num1);
    #1;
  end
  $finish;
end
//-- 生成随机数 ------------------------------------------------------------


endmodule