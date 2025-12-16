using System;
using UnityEngine;

    [RequireComponent(typeof (NewCarController))]
public class NewCarUserControl : MonoBehaviour
    {
        private NewCarController m_Car; // the car controller we want to use

        private void Awake()
        {
            // get the car controller
            m_Car = GetComponent<NewCarController>();
        }
		
		public float h,v,startV=1f,gear=1f,revFwd=1f,handbrake;
		
		void Start(){
		
	}
	
	
	public void FrontGear(){
		gear=1f;
		revFwd=startV*gear;
	}
	
	public void RearGear(){
		gear=-1f;
		revFwd=startV*gear;
	}


        private void FixedUpdate()
        {
            // pass the input to the car!
           // float h = Input.GetAxis("Horizontal");
           // float v = Input.GetAxis("Vertical");

#if !MOBILE_INPUT
           // handbrake = Input.GetAxis("Jump");
            m_Car.Move(revFwd*h, revFwd*v, revFwd*v, handbrake);
            
#else
            m_Car.Move(revFwd*h, revFwd*v, revFwd*v, handbrake);
#endif
        }
    }

