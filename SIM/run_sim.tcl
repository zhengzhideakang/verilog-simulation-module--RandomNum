# ------------------------ Global Settings ------------------------
# 动态获取仿真顶层模块名
set TOP_MODULE [get_property TOP [current_fileset -simset]]
if {$TOP_MODULE eq ""} {
    puts "== ERROR: Simulation top module not set! =="
    return 1
}

# 波形配置文件（强制绝对路径）
set WAVE_CONFIG_FILE "[file normalize "${TOP_MODULE}_behav.wcfg"]"
puts "== WaveConfig Path: [file nativename $WAVE_CONFIG_FILE] =="

# ----------------- 动态种子生成（高随机性）-----------------
set timestamp_us [clock microseconds]
set pid [pid]
set seed [expr { ($timestamp_us ^ $pid) % 999983 + 1 }]  ;# 质数取模

# ----------------- 获取仿真文件集 -----------------
set sim_sets [get_filesets -filter {FILESET_TYPE == "SimulationSrcs"}]
if {[llength $sim_sets] == 0} {
    puts "== ERROR: No simulation fileset found! =="
    return 1
}
set target_simset [lindex $sim_sets 0]

# ----------------- 保存当前波形配置 关闭现有仿真 -----------------
if {[current_sim -quiet] ne ""} {
    # 保存当前波形配置
    save_wave_config $WAVE_CONFIG_FILE
    # 关闭仿真
    close_sim -force
}

# ----------------- 修改波形配置文件中的SEED值 -----------------
if {[file exists $WAVE_CONFIG_FILE]} {
    # 读取配置文件内容
    set fp [open $WAVE_CONFIG_FILE r]
    set content [read $fp]
    close $fp

    # 使用正则表达式精确替换SEED值
    # 匹配模式：(SEED=\d+) → 替换为当前种子值
    set updated_content [regsub -all {\(SEED=\d+\)} $content "(SEED=$seed)"]

    # 写回修改后的配置
    set fp [open $WAVE_CONFIG_FILE w]
    puts $fp $updated_content
    close $fp
    puts "== Updated SEED value in wave config: $seed =="
}

# ----------------- 传递新的SEED值 启动新仿真 -----------------
set_property generic "SEED=$seed" $target_simset
puts "== Starting simulation with SEED = $seed =="
launch_simulation -simset $target_simset