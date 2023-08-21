//
//  MathSolver.swift
//  MazeDemo2
//
//  Created by Kelly Florences Tanjaya on 11/08/23.
//

import Foundation

class MathSolver: ObservableObject{
    var question: String = ""
    var answer: String = ""
    var choiceA: String = ""
    var choiceB: String = ""
    
    func generateQuestion(){                // generate ax + b = c
        var a = Int.random(in: -10..<10)
        let b = Int.random(in: -30..<30)
        let c = Int.random(in: -50..<50)
        
        // variable a can't be 0 or else it's no solution
        while a == 0 {
            a = Int.random(in: -10..<10)
        }
        
        var str_b = ""
        if(b > 0){
            str_b = " + " + String(b)
        }else{
            str_b = String(b)
        }
        
        question = "\(a) x \(str_b) = \(c)"
        solve(Double(a), Double(b), Double(c))
    }
    
    func generateChoices(ans: Double){
        choiceA = answer
        while choiceA == answer {
            let chA = Double.random(in: ans-10..<ans+10)
            choiceA = String(round(chA * 100) / 100)
        }
        
        choiceB = answer
        while choiceB == answer{
            let chB = Double.random(in: ans-10..<ans+10)
            choiceB = String(round(chB * 100) / 100)
        }
        
        print("choice a: ", choiceA, "choice b: ", choiceB)
    }
    
    func solve(_ a: Double, _ b: Double, _ c: Double) {        // solve ax + b = c
        var ans: Double
        if a == 0 {
            if b == c {
                print("Any x is a solution")
            } else {
                print("no solution")
            }
            ans = 0.0
            generateChoices(ans: ans)
        } else {
            ans = (Double(c - b)) / Double(a)
            generateChoices(ans: ans)
        }
//        answer = String(ans)
        answer = String(round(ans * 100) / 100)
        print("ans: ", answer)
    }
    
//    func resolve(equation : String) {
//        var equation = equation
//        var aCoeff = 1.0
//        var bCoeff = 0.0
//        var cCoeff = 0.0
//
//        if let xRange = equation.range(of: "x") {
//            var aStr = equation
//            aStr.removeSubrange(xRange.lowerBound..<equation.endIndex)            // remove everything after x
//            aStr = aStr.replacingOccurrences(of: " ", with: "")
//
//            if let a = Double(aStr) {
//                aCoeff = a
//            } else {        // No number just x or -x
//                if equation.first == "-" {
//                    aCoeff = -1.0
//                } else {
//                    aCoeff = 1.0        // Missing coeff, means 1 or -1
//                }
//            }
//            equation.removeSubrange(equation.startIndex...xRange.lowerBound)            // keeps only after x (+ b = c)
//        } else {                // if x missing, not an equation
//            aCoeff = 0.0
//        }
//
//        if let equalRange = equation.range(of: "=") {
//            var cStr = equation         // The shorter, without x
//            cStr.removeSubrange(equation.startIndex...equalRange.lowerBound)            // remove everything upto =, to keep only c
//            cStr = cStr.replacingOccurrences(of: " ", with: "")
//            if let c = Double(cStr) {
//                cCoeff = c
//            }
//            // Remove after = and keep only "+ b"
//            var bStr = equation
//            bStr.removeSubrange(equalRange.lowerBound..<equation.endIndex)            // remove everything after =
//            bStr = bStr.replacingOccurrences(of: " ", with: "")
//            if let b = Double(bStr) {
//                bCoeff = b
//            }
//
//        }
//
//        solve(aCoeff, bCoeff, cCoeff)
//    }
    
}
