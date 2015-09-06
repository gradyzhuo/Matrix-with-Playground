import Foundation
import Accelerate

//MARK: - Error Defines

//MARK: Error Types In Matrix
public enum MatrixError:ErrorType {
    case Undefined
    case SizeNotEqual(function:String, position:MatrixPosition, otherPosition: MatrixPosition)
    case BLAS(function: String)
    case ErrorWithStatus(status: Status)
    case ConstructWithSize
}

//MARK: Postion Define for Size Error
public enum MatrixPosition {
    case This(matrix:Matrix, size: MatrixSize)
    case Left(matrix:Matrix, size: MatrixSize)
    case Right(matrix:Matrix, size: MatrixSize)
}

//MARK: Define which size failed
public enum MatrixSize : Int {
    case Both
    case Rows
    case Cols
}

//MARK: Hint Type Redefined
public struct Hint:OptionSetType {
    
    public typealias RawValue = la_hint_t
    internal var value:RawValue
    
    public typealias Element = Hint
    /// Convert from a value of `RawValue`, succeeding unconditionally.
    public init(rawValue: RawValue){
        self.value = rawValue
    }

    public var rawValue: RawValue { return value }
    
    public static let Default = Hint.NoHint
    public static let NoHint = Hint(rawValue: la_hint_t(LA_NO_HINT))
    public static let ShapeDiagonal = Hint(rawValue: la_hint_t(LA_SHAPE_DIAGONAL))
    public static let LowerTriangular = Hint(rawValue: la_hint_t(LA_SHAPE_LOWER_TRIANGULAR))
    public static var UpperTriangular = Hint(rawValue: la_hint_t(LA_SHAPE_UPPER_TRIANGULAR))
    public static var FeatureSymmetric = Hint(rawValue: la_hint_t(LA_FEATURE_SYMMETRIC))
    public static var FeaturePositiveDefinite = Hint(rawValue: la_hint_t(LA_FEATURE_POSITIVE_DEFINITE))
    public static var FeatureDiagonallyDominant = Hint(rawValue: la_hint_t(LA_FEATURE_DIAGONALLY_DOMINANT))
}


//MARK: Attribute Type Redefined
public struct Attribute: RawRepresentable {
    
    public typealias RawValue = la_attribute_t
    internal var value:RawValue
    
    /// Convert from a value of `RawValue`, succeeding unconditionally.
    public init(rawValue: RawValue){
        self.value = rawValue
    }
    
    public var rawValue: RawValue { return value }
    
    
    public static let Default = Attribute(rawValue: la_attribute_t(LA_DEFAULT_ATTRIBUTES))
    public static let EnableLogging = Attribute(rawValue: la_attribute_t(LA_ATTRIBUTE_ENABLE_LOGGING))
}


//MARK: Scalar Type Redefined
public struct ScalarType: RawRepresentable {
    
    public typealias RawValue = la_scalar_type_t
    internal var value:RawValue
    
    /// Convert from a value of `RawValue`, succeeding unconditionally.
    public init(rawValue: RawValue){
        self.value = rawValue
    }
    
    public var rawValue: RawValue { return value }
    
    public static let Default = ScalarType.Double
    public static let Float = ScalarType(rawValue: la_scalar_type_t(LA_SCALAR_TYPE_FLOAT))
    public static let Double = ScalarType(rawValue: la_scalar_type_t(LA_SCALAR_TYPE_DOUBLE))

}


//MARK: Status Type Redefined
public struct Status: RawRepresentable {
    
    public typealias RawValue = la_status_t
    internal var value:RawValue
    
    /// Convert from a value of `RawValue`, succeeding unconditionally.
    public init(rawValue: RawValue){
        self.value = rawValue
    }
    
    public var rawValue: RawValue { return value }
    
    
    public static let Success = Status(rawValue: la_status_t(LA_SUCCESS))
    public static let WarningPoorlyConditioned = Status(rawValue: la_status_t(LA_WARNING_POORLY_CONDITIONED))
    public static let Internal = Status(rawValue: la_status_t(LA_INTERNAL_ERROR))
    public static let InvalidParameterError = Status(rawValue: la_status_t(LA_INVALID_PARAMETER_ERROR))
    public static let DimensionMismatchError = Status(rawValue: la_status_t(LA_DIMENSION_MISMATCH_ERROR))
    public static let PrecisionMismatchError = Status(rawValue: la_status_t(LA_PRECISION_MISMATCH_ERROR))
    public static let SingularError = Status(rawValue: la_status_t(LA_SINGULAR_ERROR))
    public static let SliceOutOfBoundsError = Status(rawValue: la_status_t(LA_SLICE_OUT_OF_BOUNDS_ERROR))
    
}


//MARK: - Matrix
/**
    Construct a Matrix instance for Linear Algebra.
*/
public struct Matrix {
    
    public let hint:Hint
    public let attributes:Attribute
    
    /**
        Get count of rows in current matrix.
    */
    public var rowsCount:CountType {
        return la_matrix_rows(self.object)
    }
    
    /**
        Get count of columns in current matrix.
    */
    public var colsCount:CountType {
        return la_matrix_cols(self.object)
    }
    
    /**
        la_object_t instance to calculate in Linear Algebra through BLAS library.
    */
    internal var object: la_object_t
    
    
    
    public init(object: la_object_t){
        self.object = object
        self.hint = .NoHint
        self.attributes = .Default
    }
    
    public init( entries: [Double], rows: CountType, cols: CountType, stride: CountType? = nil, hint: Hint = .Default, attributes:Attribute = .Default) throws {
        
        if Int(rows) * Int(cols) != entries.count {
            throw MatrixError.ConstructWithSize
        }
        
        self.object = la_matrix_from_double_buffer(entries, CountType(rows), cols, stride ?? cols, hint.rawValue, attributes.rawValue)
        self.hint = hint
        self.attributes = attributes
    }
    
    
    public init( entries: [[Double]], hint: Hint = Hint.Default, attribute: Attribute = .Default) throws {
            
        let flatEntries = entries.flatMap { $0 }
        
        guard let rows = entries.first?.count else {
            throw MatrixError.Undefined
        }
        
        for entryArray in entries {
            guard rows == entryArray.count else {
                throw MatrixError.Undefined
            }
        }
        
        let cols = CountType(entries.count)
        self = try Matrix(entries: flatEntries, rows: CountType(rows), cols: cols)
        
    }
    
    
}


extension Matrix {
    
    public init(vectorWithEntries entries: [Double], transpose: Bool = false, hint: Hint =
        .Default, attributes: Attribute = .Default){
            
            let rows:CountType
            let cols:CountType
            
            if transpose {
                rows = CountType(entries.count)
                cols = 1
            }else{
                rows = 1
                cols = CountType(entries.count)
            }
            
            self.object = la_matrix_from_double_buffer(entries, rows, cols, cols, hint.rawValue, attributes.rawValue)
            
            self.hint = hint
            self.attributes = attributes
    }
    
    
    public init(identifyWithSize size:CountType, scalarType: ScalarType =
        .Default, attributes: Attribute = .Default){
            
            self.object = la_identity_matrix(size, scalarType.rawValue, attributes.rawValue)
            self.attributes = attributes
            self.hint = .NoHint
    }
    
}

extension Matrix {
    
    //+
    public mutating func sum(rightMatrix matrix: Matrix) throws {
        
        guard self.colsCount == matrix.colsCount && self.rowsCount == matrix.rowsCount else {
            throw MatrixError.SizeNotEqual(function: "sum", position: .Left(matrix: self, size: .Both), otherPosition: .Right(matrix: matrix, size: .Both))
        }
        
        self.object = try self._sum(matrix.object)
        
    }
    
    //-
    public mutating func difference(rightMatrix matrix: Matrix) throws {
        
        guard self.colsCount == matrix.colsCount && self.rowsCount == matrix.rowsCount else {
            throw MatrixError.SizeNotEqual(function: "difference", position: .Left(matrix: self, size: .Both), otherPosition: .Right(matrix: matrix, size: .Both))
        }
        
        self.object = try self._difference(matrix.object)
        
    }
    
    //*
    public mutating func product(rightMatrix matrix: Matrix) throws{
        
        guard self.colsCount == matrix.rowsCount else {
            throw MatrixError.SizeNotEqual(function: "product", position: .Left(matrix: self, size: .Cols), otherPosition: .Right(matrix: matrix, size: .Rows))
        }
        
        self.object = try self._product(matrix.object)
        
    }
    

    //逆矩陣
    public mutating func inverse() throws {
        
        guard self.rowsCount != self.colsCount else  {
            //不是方陣
            throw MatrixError.SizeNotEqual(function: "inverse", position: .This(matrix: self, size: .Rows), otherPosition: .This(matrix: self, size: .Rows))
        }
        
        self.object = try self._inverse()
        
    }
    
    
    //轉置
    public mutating func transpose(){
        self.object = la_transpose(self.object)
    }
    
    
    
    
}


extension Matrix {
    
    //+
    public func matrixWithSum(rightMatrix matrix: Matrix) throws -> Matrix{
        
        guard self.colsCount == matrix.colsCount && self.rowsCount == matrix.rowsCount else {
            throw MatrixError.SizeNotEqual(function: "matrixWithSum", position: .Left(matrix: self, size: .Both), otherPosition: .Right(matrix: matrix, size: .Both))
        }
        
        let result = try self._sum(matrix.object)
        return Matrix(object: result)
        
    }
    
    //-
    public func matrixWithDifference(rightMatrix matrix: Matrix) throws -> Matrix{
        
        guard self.colsCount == matrix.colsCount && self.rowsCount == matrix.rowsCount else {
            throw MatrixError.SizeNotEqual(function: "matrixWithDifference",position: .Left(matrix: self, size: .Both), otherPosition: .Right(matrix: matrix, size: .Both))
        }
        
        let result = try self._difference(matrix.object)
        return Matrix(object: result)
        
    }
    
    //*
    public func matrixWithProduct(rightMatrix matrix: Matrix) throws -> Matrix{
        
        guard self.colsCount == matrix.rowsCount else {
            throw MatrixError.SizeNotEqual(function: "matrixWithProduct",position: .Left(matrix: self, size: .Cols), otherPosition: .Right(matrix: matrix, size: .Rows))
        }
        
        let result = try self._product(matrix.object)
        return Matrix(object: result)
        
    }
    
    //解聯立
    public func matrixWithSolve(rightMatrix matrix: Matrix) throws -> Matrix{
        let result = try self._solve(matrix.object)
        return Matrix(object: result)
    }
    
    //逆矩陣
    public func matrixWithInverse() throws -> Matrix {
        
        guard self.rowsCount == self.colsCount else  {
            //不是方陣
            throw MatrixError.SizeNotEqual(function: "matrixWithInverse", position: .This(matrix: self, size: .Rows), otherPosition: .This(matrix: self, size: .Cols))
        }
        
        let result = try self._inverse()
        return Matrix(object: result)
    }
    
    
    //轉置
    public func matrixWithTranspose() -> Matrix {
        let result = self._transpose()
        return Matrix(object: result)
        
    }
    
    
    
    
}

extension Matrix {
    
    //get entries
    public func entries() throws -> [Double] {
        
        let totalCount = Int(self.rowsCount * self.colsCount)
        
        var result:[Double] = [Double](count:totalCount, repeatedValue: 0)
        let res = la_matrix_to_double_buffer(&result, CountType(self.colsCount), self.object)
        
        let status = Status(rawValue: res)
        
        //If no error occurred, print result
        if status == .Success {
            return result
        }else{
            throw MatrixError.ErrorWithStatus(status: status)
        }
    }
    
}

//MARK: - Calculate by BLAS
extension Matrix {
    
    //+
    internal func _sum(right : la_object_t) throws -> la_object_t{
        
        let left = self.object
        
        guard let result = la_sum(left, right) else {
            throw MatrixError.BLAS(function: "la_sum")
        }
        
        return result
        
    }
    
    //-
    internal func _difference(right : la_object_t) throws -> la_object_t{
        
        let left = self.object
        
        guard let result = la_difference(left, right) else {
            throw MatrixError.BLAS(function: "la_difference")
        }
        
        return result
        
    }
    
    //*
    internal func _product(right : la_object_t) throws -> la_object_t{
        let left = self.object
        
        guard let result = la_matrix_product(left, right) else{
            throw MatrixError.BLAS(function: "la_matrix_product")
        }
        
        return  result
        
    }
    
    //解聯立
    internal func _solve(right : la_object_t) throws -> la_object_t{
        let left = self.object
        
        guard let result = la_solve(left, right) else{
            throw MatrixError.BLAS(function: "la_solve")
        }
        
        return result
        
    }
    
    
    //逆矩陣
    internal func _inverse() throws -> la_object_t {
        
        guard let identity = la_identity_matrix(self.rowsCount, la_scalar_type_t(LA_SCALAR_TYPE_DOUBLE), la_attribute_t(LA_DEFAULT_ATTRIBUTES)) else {
            throw MatrixError.BLAS(function: "la_identity_matrix")
        }
        
        return try self._solve(identity)
    }
    
    
    //轉置
    internal func _transpose() -> la_object_t {
        let result = la_transpose(self.object)
        return result
        
    }

}


//MARK: - Typealiases
extension Matrix {
    public typealias CountType = la_count_t
}

//MARK: - Protocol Implement 
extension Matrix : CustomStringConvertible, Equatable {
    
    public var description:String{
        
        let entriesStrings:String = (try? self.entries().map{ String($0) }.joinWithSeparator(",")) ?? "failed"
        return "Martix (rows:\(self.rowsCount),cols:\(self.colsCount))=> [\(entriesStrings)]"
    }
    
}

//MARK: - Equatable Protocol Implement

public func ==(lhs: Matrix, rhs: Matrix) -> Bool {
    
    guard let lEntries = try? lhs.entries() else{
        return false
    }
    guard let rEntries = try? rhs.entries() else{
        return false
    }
    
    guard lhs.colsCount == rhs.colsCount && lhs.rowsCount == rhs.rowsCount else {
        return false
    }
    
    return lEntries.elementsEqual(rEntries)
}

//MARK: - Operator Function

public func +(lhs: Matrix, rhs:Matrix) throws -> Matrix {
    return try lhs.matrixWithSum(rightMatrix: rhs)
}

public func -(lhs: Matrix, rhs:Matrix) throws -> Matrix {
    return try lhs.matrixWithDifference(rightMatrix: rhs)
}

public prefix func -(rhs: Matrix) throws -> Matrix {
    return try rhs.matrixWithInverse()
}

public func *(lhs: Matrix, rhs:Matrix) throws -> Matrix {
    return try lhs.matrixWithProduct(rightMatrix: rhs)
}

public func ~>(lhs:Matrix, rhs:Matrix) throws -> Matrix {
    return try lhs.matrixWithSolve(rightMatrix: rhs)
}

