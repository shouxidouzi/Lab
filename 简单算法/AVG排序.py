
def sort_by_avg(arr):
    #如果不能再分,exmale:arr[2]，则直接返回
    if len(arr) <= 1:
        return arr

    avg = sum(arr) / len(arr)#计算平均值
    mid = [x for x in arr if x == avg] #分区3，等于平均值
    if len(mid)==len(arr):return arr
    left = [x for x in arr if x < avg]#分区1，小于平均值
   
    

    right = [x for x in arr if x > avg]#分区2，大于平均值
    #递归调用
    return sort_by_avg(left) + mid + sort_by_avg(right)


print(sort_by_avg([-1,7,2.5,9,-10,5,4,6,3,8,1.1]))


#精简版
def avg_sort(arr):
    if len(arr)<=1:return arr
    a=sum(arr)/len(arr)
    l,m,r=[],[],[]
    for x in arr:
        (l if x<a else r if x>a else m).append(x)
    return arr if len(m)==len(arr) else avg_sort(l)+m+avg_sort(r)
