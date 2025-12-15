using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZoomSwipe : MonoBehaviour
{
    public float rotationSpeed = 5.0f;
    public float maxRotationX = 25f;
    public float minRotationX = -18f;
    public float maxRotationY = 65f;
    public float minRotationY = -90f;
    public float smoothFactor = 5f; // Adjust the smooth factor as needed

    private bool isRotating = false;
    private Vector2 lastMousePos;
    private float swipeMagnitudeThreshold = 15f; // Adjust the threshold as needed for swipe distance
    private float minSwipeSpeed = 200f; // Adjust the minimum swipe speed as needed

    void Update()
    {
        if (gameObject.transform.GetComponent<ZoomSystem>().isPointerDown)
        {
            isRotating = true;
            lastMousePos = Input.mousePosition;
        }
        else if (gameObject.transform.GetComponent<ZoomSystem>().isPointerDown)
        {
            isRotating = false;
        }

        if (isRotating)
        {
            Vector2 swipeDelta = (Vector2)Input.mousePosition - lastMousePos;

            float swipeMagnitude = swipeDelta.magnitude;
            float swipeSpeed = swipeMagnitude / Time.deltaTime;

            if (swipeMagnitude >= swipeMagnitudeThreshold && swipeSpeed >= minSwipeSpeed)
            {
                float rotationX = -swipeDelta.y * rotationSpeed * Time.deltaTime;
                float rotationY = swipeDelta.x * rotationSpeed * Time.deltaTime;

                lastMousePos = Input.mousePosition;

                Vector3 currentRotation = transform.localRotation.eulerAngles;

                float newRotationX = currentRotation.x + rotationX;
                float newRotationY = currentRotation.y + rotationY;

                newRotationX = (newRotationX < 0) ? newRotationX + 360f : newRotationX % 360f;
                newRotationY = (newRotationY < 0) ? newRotationY + 360f : newRotationY % 360f;

                if (newRotationX > 180f)
                {
                    newRotationX -= 360f;
                }
                if (newRotationY > 180f)
                {
                    newRotationY -= 360f;
                }

                newRotationX = Mathf.Clamp(newRotationX, minRotationX, maxRotationX);
                newRotationY = Mathf.Clamp(newRotationY, minRotationY, maxRotationY);

                if (newRotationX < 0)
                {
                    newRotationX += 360f;
                }

                if (newRotationY < 0)
                {
                    newRotationY += 360f;
                }

                Quaternion targetRotation = Quaternion.Euler(newRotationX, newRotationY, 0);
                transform.localRotation = Quaternion.Lerp(transform.localRotation, targetRotation, smoothFactor * Time.deltaTime);
            }
        }
    }
}
