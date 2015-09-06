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
