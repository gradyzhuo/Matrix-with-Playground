//: [Previous](@previous)

import Foundation
import Accelerate

//使用splat，做出一個vector

let splatA = la_splat_from_double(1.0, la_attribute_t(LA_DEFAULT_ATTRIBUTES))
let vecY = la_vector_from_splat(splatA, 5)
let matZ = la_matrix_from_splat(splatA, 3, 1)


print(vecY)
// 2.0
// 2.0
// 2.0
// 2.0
// 2.0
// 2.0
print(matZ)
// 2.0 2.0 2.0
// 2.0 2.0 2.0



do{
    
    let a = try Matrix(entries: [1,1,1], rows: 3, cols: 3, stride: 1, hint: la_hint_t(LA_NO_HINT), attribute: la_attribute_t(LA_DEFAULT_ATTRIBUTES))
    
}catch{
    print(error)
}

