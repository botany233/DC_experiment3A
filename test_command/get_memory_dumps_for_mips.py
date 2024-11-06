import os

def extract_instructions(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for index, line in enumerate(infile):
            data = line.split(":")[1].split(";")[0].strip(" ")
            if all(c in "0123456789abcdefABCDEF" for c in data):
                outfile.write(data + '\n')
            else:
                print(f"Warnning: unexpected data '{data}' in line {index}")

work_file = r"C:\Users\18201\Desktop\verilog\DC_experiment3A\test_command"
input_filename = os.path.join(work_file, 'assembly_result_online.txt')  # 输入文件名
output_filename = os.path.join(work_file, 'output_command.txt')  # 输出文件名
extract_instructions(input_filename, output_filename)