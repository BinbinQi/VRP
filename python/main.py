from Util import Factory, VRP
import time

start_time = time.time()
file_path = r"D:\CRVP\data\P-n19-k2.vrp"
# file_path = r"D:\CRVP\data\A-n32-k5.vrp"

# vrp = Factory.CreateProblem(VRP.Miller_Tucker_Zemlin, file_path)
vrp = Factory.CreateProblem(VRP.Ortools_method, file_path)
# vrp = Factory.CreateProblem(VRP.Miller_Tucker_Zemlin, file_path)
vrp.parseFile()
vrp.solve()
vrp.displayResult()
end_time = time.time()
print("程序运行时间：", end_time-start_time, "秒")
