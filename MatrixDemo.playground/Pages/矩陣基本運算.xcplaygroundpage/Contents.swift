//: [Previous](@previous)

import Foundation


/*
        | 1   2 |
 m1 :   |       |
        | 3   4 |

        | 3  -2 |
 m2 :   |       |
        | 5   0 |

*/


do{
    
    let m1 = try Matrix(entries: [1, 2, 3, 4], rows: 2, cols: 2)
    let m2 = try Matrix(entries: [3,-2, 5, 0], rows: 2, cols: 2)
    
    /*sum result
    | 4   0 |
    |       | => [4, 0, 8, 4]
    | 8   4 |
    */
    let sum = try m1 + m2
    
    
    /* m1 - m2 result
    | -2   4 |
    |        | => [-2, 4, -2, 4]
    | -2   4 |
    */
    let diff = try m1 - m2
    
    
    /* m2 - m1 result
    | 2   -4 |
    |        | => [2, -4, 2, -4]
    | 2   -4 |
    */
    let diff2 = try m2 - m1
    
    
    /*product result
    | 13  -2 |
    |        | => [13, -2, 29, -6]
    | 29  -6 |
    */
    let product = try m1 * m2
    
    
    /*inverse m1 result
    | -2    1  |
    |          | => [-2, 1, 3/2, -1/2]
    | 3/2 -1/2 |
    */
    let inverse = try -m1
    
    
    /*inverse m2 result
    | 0     2/10 |
    |            | => [0, 1/5, -1/2, 3/10]
    | -5/10 3/10 |
    */
    
    let inverseM2 = try -m2
    
}catch{
    print("error:\(error)")
}

//: [Next](@next)
