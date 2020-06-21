using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AddRandomForce : MonoBehaviour
{
    public Rigidbody m_toTarget;
    public float m_forceMultiplicate =2f;

    [ContextMenu("Add Force")]
    public void AddForce()
    {
        m_toTarget.AddForce(new Vector3(
            Random.value* m_forceMultiplicate, 
            Random.value* m_forceMultiplicate
            , Random.value*m_forceMultiplicate)
            ,ForceMode.Impulse);
    }

}
