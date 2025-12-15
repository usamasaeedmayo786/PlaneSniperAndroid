using UnityEngine;
using DG.Tweening;
public class SwipeRotate : MonoBehaviour
{
    public float rotationSpeed = 5.0f;
    public float maxRotationX = 25f;
    public float minRotationX = -18f;
    public float maxRotationY = 65f;
    public float minRotationY = -90f;

    private bool isRotating = false;
    private Vector2 lastMousePos;

    void Update()
    {

        //transform.DOShakePosition(duration, strength, vibrato, randomness).SetEase(Ease.InOutQuad);


        if (Input.GetMouseButtonDown(0))
        {
            isRotating = true;
            lastMousePos = Input.mousePosition;
        }
        else if (Input.GetMouseButtonUp(0))
        {
            isRotating = false;
        }

        if (isRotating)
        {
            Vector2 swipeDelta = (Vector2)Input.mousePosition - lastMousePos;
            float rotationX = -swipeDelta.y * rotationSpeed * Time.deltaTime;
            float rotationY = swipeDelta.x * rotationSpeed * Time.deltaTime;

            lastMousePos = Input.mousePosition;

            Vector3 currentRotation = transform.localEulerAngles;

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

            //Quaternion newRotation = Quaternion.Euler(newRotationX, newRotationY, 0);
            transform.localEulerAngles = new Vector3(newRotationX, newRotationY, 0);
        }
    }
}