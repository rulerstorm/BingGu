ver: 1.0     
date: 20151103     

## check ticket     
##### URL: 
http://120.27.54.111:8080/index.php     
##### GET:      
    - id (the card ID you want to check)     
##### return type: json     
    - validate: 200(sucess) or 0(fail)     
    - enterCount: a number (if sucess)     

## change ticket     
##### URL: 
http://120.27.54.111:8080/changeTicket.php     
##### GET:      
    - id (the card ID you want to change)     
    - toID (change to this ID)     
##### return type: json    
    - validate: 200(sucess) or 0(fail)    

## refound     
##### URL: 
http://120.27.54.111:8080/updateMoney.php     
##### GET:     
    - id (the ID need refound)     
    - money `(important!! this value should be -1)`     
##### return type: json    
    - validate: 200(sucess) or 0(fail)       


## top up      
##### URL: 
http://120.27.54.111:8080/updateMoney.php     
##### GET:     
    - id (the ID need refound)     
    - money `(important!! this value should be a positive value and the value is how much the customer top uped)`     
##### return type: json    
    - validate: 200(sucess) or 0(fail)      


## get statistic values     
##### URL: 
http://120.27.54.111:8080/statistic.php     
##### GET:     
    - lastID (the last ID on your phone, for finding the event it belongs to)     
##### return type: json    
    - validate: 200(sucess) or 0(fail)      
    - A: a number (the total number of A-tpye card) (if sucess)     
    - B: a number (the total number of B-tpye card) (if sucess)     
    - C: a number (the total number of C-tpye card) (if sucess)     
    - D: a number (the total number of D-tpye card) (if sucess)     
    - E: a number (the total number of E-tpye card) (if sucess)     
    

    
