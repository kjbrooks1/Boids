# Boids - Flocking Simulation
-----------------------------

Boids are an algoirthmic name for the objects used to simulate the flocking of birds. This idea was first created by Craig Reynolds in 1986. More can be read about it [here](https://en.wikipedia.org/wiki/Boids). Here I've recreated the Boids simulation using Swift and Apple's Metal Graphics API.


![The final result](https://github.com/kjbrooks1/Boids/blob/main/BOIDS-SIMULATION-FINAL.gif)


### 3 Basic Rules of a Boid
---------------------------
**1. Seperation**
Steer away from nearby Boids to avoid collisions

```
func seperation(boid: Boid) -> SIMD2<Float> {
    let minDistance: Float = 0.15
    var nearbyVect = SIMD2<Float>(0,0)
    for other in BOIDS {
        if(other !== boid && distance(a: boid, b: other) <= minDistance){
            nearbyVect += (other.position - boid.position)
        }
    }
    return -1 * nearbyVect
}
```

**2. Alignment**
Rotate to move in the same direction as other Boids

```
func alignment(boid: Boid) -> SIMD2<Float> {
    let minDistance: Float = 0.15
    var nearbyVect = SIMD2<Float>(0,0)
    var neighborCount: Float = 0
    for other in BOIDS {
        if(other !== boid && distance(a: boid, b: other) <= minDistance){
            nearbyVect += other.velocity
            neighborCount += 1
        }
    }
    if(neighborCount == 0){
        return nearbyVect
    }
    return simd_normalize(nearbyVect / neighborCount)
}
                                                                     
 ```

**3. Cohesion**
Move towards the center of nearby Boids

```
func cohesion(boid: Boid) -> SIMD2<Float> {
      let minDistance: Float = 0.15
      var nearbyVect = SIMD2<Float>(0,0)
      var neighborCount: Float = 0
      for other in BOIDS {
          if(other !== boid && distance(a: boid, b: other) <= minDistance){
              nearbyVect += other.position
              neighborCount += 1
          }
      }

      if(neighborCount == 0){
          return nearbyVect
      }
      nearbyVect /= neighborCount
      return simd_normalize(nearbyVect  - boid.position)
  }
```


