//: [Previous](@previous)

import Foundation
import Accelerate

var str = "Hello, playground"

//: [Next](@next)

var a:[Double] = [1,2, 3,4]
var aMatrix = la_matrix_from_double_buffer(&a, 2, 2,2, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))

var b:[Double] = [6, 10]
var bMatrix = la_matrix_from_double_buffer(&b, 2, 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))

var s = la_solve(aMatrix, bMatrix)//la_matrix_product(aMatrix, bMatrix)


s = la_matrix_product(aMatrix, bMatrix)





//let identity = 
//let aTranspose = la_solve(aMatrix, identity)

//printMatrix(aTranspose)



func printMatrix(m:la_object_t){
    //Calculate result and send it to the variable "result"
    var result:[Double] = [Double](count:9, repeatedValue: 0)
    var res = la_matrix_to_double_buffer(&result, 1, m)
    
    //If no error occurred, print result
    if Int32(res) == LA_SUCCESS {
        print("ok")
        print(result)
    }else{
        print("wrong")
    }
}



//var b:[Double] =
var c = la_matrix_from_double_buffer([1,1,1], 3, 1, 1, la_hint_t(LA_NO_HINT), la_attribute_t(LA_DEFAULT_ATTRIBUTES))
printMatrix(c)
