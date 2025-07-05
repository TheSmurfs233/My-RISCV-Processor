import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import serial
import serial.tools.list_ports
import os
import time
import platform

class HexDownloaderApp:
    def __init__(self, root):
        self.root = root
        self.root.title("HEX文件下载工具")
        self.root.geometry("700x500")
        
        # 设置中文字体
        self.font = self.get_chinese_font()
        
        # 创建日志区域和状态栏变量（提前创建）
        self.log_text = None
        self.status_var = tk.StringVar()
        self.status_var.set("初始化中...")
        
        # 串口选择
        tk.Label(root, text="选择串口:", font=self.font).grid(row=0, column=0, padx=10, pady=10, sticky="w")
        self.port_var = tk.StringVar()
        self.port_combo = ttk.Combobox(root, textvariable=self.port_var, width=40, font=self.font)
        self.port_combo.grid(row=0, column=1, padx=10, pady=10, sticky="we")
        
        # 刷新串口按钮
        tk.Button(root, text="刷新串口", command=self.refresh_ports, font=self.font).grid(row=0, column=2, padx=10, pady=10)
        
        # 项目文件选择
        tk.Label(root, text="选择文件:", font=self.font).grid(row=1, column=0, padx=10, pady=10, sticky="w")
        self.file_var = tk.StringVar()
        tk.Entry(root, textvariable=self.file_var, width=50, font=self.font).grid(row=1, column=1, padx=10, pady=10, sticky="we")
        tk.Button(root, text="浏览...", command=self.browse_file, font=self.font).grid(row=1, column=2, padx=10, pady=10)
        
        # 波特率选择
        tk.Label(root, text="波特率:", font=self.font).grid(row=2, column=0, padx=10, pady=10, sticky="w")
        self.baudrate_var = tk.IntVar(value=115200)
        baudrates = [9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600]
        ttk.Combobox(root, textvariable=self.baudrate_var, values=baudrates, width=10, font=self.font).grid(row=2, column=1, padx=10, pady=10, sticky="w")
        
        # 日志区域
        tk.Label(root, text="操作日志:", font=self.font).grid(row=3, column=0, padx=10, pady=5, sticky="w")
        self.log_text = tk.Text(root, height=10, font=self.font)
        self.log_text.grid(row=4, column=0, columnspan=3, padx=10, pady=5, sticky="nsew")
        self.log_text.config(state=tk.DISABLED)
        
        # 进度条
        self.progress = ttk.Progressbar(root, orient=tk.HORIZONTAL, length=500, mode='determinate')
        self.progress.grid(row=5, column=0, columnspan=3, padx=10, pady=10)
        
        # 下载按钮
        tk.Button(root, text="下载文件", command=self.download_hex, height=2, width=15, font=self.font).grid(
            row=6, column=0, columnspan=3, pady=20)
        
        # 状态栏
        status_bar = tk.Label(root, textvariable=self.status_var, bd=1, relief=tk.SUNKEN, anchor=tk.W, font=self.font)
        status_bar.grid(row=7, column=0, columnspan=3, sticky="we")
        
        # 配置网格布局
        root.columnconfigure(1, weight=1)
        root.rowconfigure(4, weight=1)
        
        # 现在安全地刷新串口
        self.refresh_ports()
    
    def get_chinese_font(self):
        """获取适合当前系统的中文字体"""
        system = platform.system()
        if system == "Windows":
            return ("Microsoft YaHei", 10)
        elif system == "Darwin":  # macOS
            return ("PingFang SC", 12)
        else:  # Linux
            return ("WenQuanYi Micro Hei", 12)
    
    def refresh_ports(self):
        """刷新可用串口列表并显示详细信息"""
        ports_info = []
        port_map = {}  # 存储显示文本到实际设备名的映射
        
        try:
            # 获取所有可用串口
            ports = serial.tools.list_ports.comports()
            
            for port in ports:
                # 构建显示文本：描述 + 设备名
                if port.description:
                    display_text = f"{port.description}"
                else:
                    display_text = port.device
                
                ports_info.append(display_text)
                port_map[display_text] = port.device
            
            # 存储映射关系供后续使用
            self.port_map = port_map
            
            # 更新组合框
            self.port_combo['values'] = ports_info
            if ports_info:
                self.port_combo.current(0)
            
            self.status_var.set(f"找到 {len(ports_info)} 个串口")
            
            # 现在安全地记录消息
            if self.log_text:
                self.log_message(f"已刷新串口列表，找到 {len(ports_info)} 个串口")
        
        except Exception as e:
            # 使用状态栏显示错误
            self.status_var.set(f"刷新串口失败: {str(e)}")
            
            # 如果日志已创建，记录错误
            if self.log_text:
                self.log_message(f"刷新串口列表错误: {str(e)}")
    
    def browse_file(self):
        """浏览并选择文件"""
        file_path = filedialog.askopenfilename(
            title="选择文件",
            filetypes=[("所有文件", "*.*"), ("HEX文件", "*.hex"), ("二进制文件", "*.bin")]
        )
        if file_path:
            self.file_var.set(file_path)
            self.status_var.set(f"已选择文件: {os.path.basename(file_path)}")
            self.log_message(f"已选择文件: {file_path}")
    
    def log_message(self, message):
        """在日志区域添加消息"""
        if not self.log_text:
            return  # 如果日志控件尚未创建，则跳过
        
        self.log_text.config(state=tk.NORMAL)
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)  # 自动滚动到底部
        self.log_text.config(state=tk.DISABLED)
        self.status_var.set(message)
        self.root.update()  # 更新UI
    
    def parse_file(self, file_path):
        """
        解析文件内容
        支持两种格式:
        1. 每行8个十六进制字符（32位指令），例如"0fc11117"
        2. 二进制文件直接读取
        返回格式: [0x0f, 0xc1, 0x11, 0x17, ...]
        """
        data_bytes = []
        line_num = 0
        valid_lines = 0
        skipped_lines = 0

        try:
            self.log_message(f"开始解析文件: {file_path}")
            
            # 检查文件大小
            file_size = os.path.getsize(file_path)
            self.log_message(f"文件大小: {file_size} 字节")
            
            # 尝试解析为文本文件（HEX格式）
            try:
                with open(file_path, 'r') as f:
                    for line in f:
                        line_num += 1
                        # 去除空白字符和注释
                        line = line.strip()

                        # 跳过空行
                        if not line:
                            skipped_lines += 1
                            continue
                        
                        # 跳过注释行（以';'或'#'开头）
                        if line.startswith(';') or line.startswith('#'):
                            skipped_lines += 1
                            continue
                        
                        # 去除可能的地址前缀（如"0x"或"0X"）
                        if line.lower().startswith('0x'):
                            line = line[2:]

                        # 检查行长度（应该为8个字符表示32位）
                        if len(line) < 8:
                            self.log_message(f"警告: 行 {line_num} 长度不足8字符 ({len(line)}字符), 已跳过")
                            skipped_lines += 1
                            continue
                        
                        # 如果长度超过8，取前8个字符（32位）
                        if len(line) > 8:
                            self.log_message(f"警告: 行 {line_num} 长度超过8字符 ({len(line)}字符), 取前8字符")
                            line = line[:8]

                        try:
                            # 将32位指令拆分为4个字节
                            byte1 = int(line[0:2], 16)
                            byte2 = int(line[2:4], 16)
                            byte3 = int(line[4:6], 16)
                            byte4 = int(line[6:8], 16)

                            # 添加到结果列表（按照从高位到低位的顺序）
                            data_bytes.extend([byte1, byte2, byte3, byte4])
                            valid_lines += 1

                        except ValueError as e:
                            self.log_message(f"错误: 行 {line_num} 包含无效十六进制字符 '{line}' - {str(e)}")
                            skipped_lines += 1
                            continue
                    
                self.log_message(f"解析为文本格式: 处理了 {line_num} 行")
                self.log_message(f"有效行: {valid_lines}, 跳过行: {skipped_lines}")
            
            except UnicodeDecodeError:
                # 如果文本解析失败，尝试作为二进制文件读取
                self.log_message("文件不是文本格式，尝试作为二进制文件读取")
                with open(file_path, 'rb') as f:
                    data_bytes = list(f.read())
                self.log_message(f"作为二进制文件读取: 提取 {len(data_bytes)} 字节")
            
            # 打印提取结果
            self.log_message(f"总共提取 {len(data_bytes)} 字节 ({len(data_bytes)//4} 条指令)")

            # 打印前16字节预览
            if data_bytes:
                preview = ' '.join(f"{b:02X}" for b in data_bytes[:16])
                self.log_message(f"数据预览: {preview}{'...' if len(data_bytes) > 16 else ''}")
            else:
                self.log_message("警告: 未提取到任何有效数据")

            return data_bytes

        except Exception as e:
            self.log_message(f"解析文件时出错: {str(e)}")
            return []
    
    def download_hex(self):
        """下载文件到串口，按字节顺序发送"""
        # 从映射中获取实际设备名
        display_text = self.port_var.get()
        if not display_text:
            messagebox.showerror("错误", "请选择串口", parent=self.root)
            return
            
        # 尝试从映射中获取设备名
        port = None
        if display_text in self.port_map:
            port = self.port_map[display_text]
        else:
            # 尝试直接使用显示文本
            port = display_text
            self.log_message(f"警告: 串口 '{display_text}' 不在映射中，尝试直接使用")
        
        # 获取波特率
        baudrate = self.baudrate_var.get()
        
        # 获取选择的文件路径
        file_path = self.file_var.get()
        if not file_path:
            messagebox.showerror("错误", "请选择文件", parent=self.root)
            return

        # 验证文件是否存在
        if not os.path.exists(file_path):
            messagebox.showerror("错误", f"文件不存在:\n{file_path}", parent=self.root)
            return
        
        try:
            # 初始化串口
            self.log_message(f"正在连接串口: {port}...")
            ser = serial.Serial(
                port=port,
                baudrate=baudrate,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=1
            )
            
            # 确保串口已打开
            if not ser.is_open:
                ser.open()
            
            self.log_message(f"已连接串口: {port}, 波特率: {baudrate}")
            
            # 解析文件为字节列表
            self.log_message("解析文件...")
            data_bytes = self.parse_file(file_path)

            total_bytes = len(data_bytes)
            
            if total_bytes == 0:
                self.log_message("错误: 未找到有效数据")
                messagebox.showerror("错误", "文件中未找到有效数据", parent=self.root)
                return
            
            file_name = os.path.basename(file_path)
            self.log_message(f"开始下载 {file_name}...")
            self.log_message(f"有效数据字节数: {total_bytes}")
            
            # 配置进度条
            self.progress["maximum"] = total_bytes
            bytes_sent = 0
            
            # 按字节顺序发送数据
            for i, byte in enumerate(data_bytes):
                # 发送单个字节
                ser.write(bytes([byte]))
                bytes_sent += 1
                
                # 更新进度
                self.progress["value"] = bytes_sent
                
                # 每发送256字节更新一次日志
                if bytes_sent % 256 == 0 or bytes_sent == total_bytes:
                    percent = bytes_sent / total_bytes * 100
                    self.log_message(f"已发送: {bytes_sent}/{total_bytes} 字节 ({percent:.1f}%)")
                
                # 短延时防止数据丢失
                time.sleep(0.001)
            
            self.log_message("下载完成!")
            self.log_message("等待设备处理...")
            time.sleep(2)  # 给设备处理时间
            
            # 关闭串口
            ser.close()
            self.log_message("串口已关闭")
            
        except serial.SerialException as e:
            self.log_message(f"串口错误: {str(e)}")
            messagebox.showerror("串口错误", f"串口操作失败: {str(e)}", parent=self.root)
        except Exception as e:
            self.log_message(f"错误: {str(e)}")
            messagebox.showerror("下载错误", f"发生错误: {str(e)}", parent=self.root)
        finally:
            try:
                if 'ser' in locals() and ser.is_open:
                    ser.close()
            except:
                pass
            self.progress["value"] = 0
            self.status_var.set("下载完成")

if __name__ == "__main__":
    root = tk.Tk()
    app = HexDownloaderApp(root)
    root.mainloop()