//
//  ViewController.swift
//  AR_Ruler
//
//  Created by Strats 360 on 25/12/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // checking points should not be more than 2
        if dotNodes.count >= 2{
            for dot in dotNodes{
                // removing Nodes from Node array
                dot.removeFromParentNode()
            }
            // making array empty
            dotNodes = [SCNNode]()
        }
        // Adding Dot on touched location
        if let touchLocation = touches.first?.location(in: sceneView){
            let results = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal)
            // Converting rayCastQuery to Array of RaycastResult
            let hitTestResult = sceneView.session.raycast(results!)
            
            if let hitResult = hitTestResult.first{
                 addDot(at: hitResult)
                print(hitResult )
            }
                
        }
    }
    func addDot(at hitResult : ARRaycastResult){
        // declaring dot geometry using SCNsphere
        let dotGeometry = SCNSphere(radius: 0.005)
        // declaring Dot material
        let dotMaterial = SCNMaterial()
        // adding material to dot
        dotMaterial.diffuse.contents = UIColor.red
        //
        dotGeometry.materials = [dotMaterial]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                      y: hitResult.worldTransform.columns.3.y + dotGeometry.boundingSphere.radius,
                                      z: hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2{
            calculate()
        }
        
    }
    // Calculating distance between points.
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
//        let distance = sqrtf((a * a) + (b * b) + (c * c))
        let distance =  sqrtf(pow((end.position.x - start.position.x), 2) + pow((end.position.y - start.position.y), 2) + pow((end.position.z - start.position.z), 2))
        updateText(text: "\(abs(distance) * 100) cm", atPosition: end.position)
    }
    func updateText(text: String, atPosition txtposition: SCNVector3){
        
        textNode.removeFromParentNode()
        
        // ScnText help to create 3D text on Screen.
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        // We are assigning material to text
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        // Creating Node of textGeometry
         textNode = SCNNode(geometry: textGeometry)
        
        // Assigning possition to node
        textNode.position = SCNVector3(x: txtposition.x - 0.1, y: txtposition.y + 0.01, z: txtposition.z + 0.1)
        
        // User is Scaling down to 1%
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        // added node to sceneView
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }

    // MARK: - ARSCNViewDelegate
    
}
