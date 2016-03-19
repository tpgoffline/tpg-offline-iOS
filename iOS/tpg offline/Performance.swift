import Foundation

public typealias MeasuredBlock = ()->Void

//
// Calls a particular block the specified number of times, returning the average
// number of seconds it took to complete the code. If a name is supplied the time
// take for each iteration will be recorded
//
public func measure(name:String? = nil,iterations:Int = 10,forBlock block:MeasuredBlock)->Double{
    precondition(iterations > 0, "Iterations must be a positive integer")
    
    var total : Double = 0
    var samples = [Double]()
    
    for _ in 0..<iterations{
        let start = NSDate.timeIntervalSinceReferenceDate()
        block()
        let took = Double(NSDate.timeIntervalSinceReferenceDate() - start)
        
        if let name = name {
            print(took)
        }
        
        samples.append(took)
        
        total += took
    }
    
    let mean = total / Double(iterations)

    if let name = name {

        var deviation = 0.0
        
        for result in samples {
            
            let difference = result - mean
            
            deviation += difference*difference
        }
        
        let variance = deviation / Double(iterations)
        
        let formatter = NSDateComponentsFormatter()
        formatter.allowedUnits = NSCalendarUnit.Second
        formatter.allowsFractionalUnits = true
        
        print("\(name) Average \(mean.milliSeconds)")
        print("\(name) STD Dev. \(variance.milliSeconds)")
    }
    
    return mean
}

extension Double{
    
    var milliSeconds : String {
        return String(format: "%03.2fms", self*1000)
    }
    
}

