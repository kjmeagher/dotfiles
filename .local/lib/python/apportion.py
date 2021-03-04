def apportion_ints(n,ratio):
    """
    Divide the number n into a list of integers which approximatly match the given ratios
    whose sum is exactly n

    returns:
      a list of integers whose sum is n and approximaly match the given ratios

    """
    total = sum(ratio)
    fracs = [n*x/total for x in ratio]
    whole,remain = list(zip(*[divmod(x,1) for x in fracs]))
    whole=[int(x) for x in whole]
    for i,r in sorted(enumerate(remain),key=lambda x: x[1],reverse=True)[:n-sum(whole)]:
        whole[i]+=1

    assert sum(whole)==n

    return whole


if __name__=='__main__':

    assert apportion_ints(9,[5,2,2,2,2])==[4, 2, 1, 1, 1]
    assert apportion_ints(10,[5,2,2,2,2])==[4, 2, 2, 1, 1]
    assert apportion_ints(11,[5,2,2,2,2])==[4, 2, 2, 2, 1]
    assert apportion_ints(12,[5,2,2,2,2])==[4, 2, 2, 2, 2]

    
    

