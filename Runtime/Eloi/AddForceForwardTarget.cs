using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AddForceForwardTarget : MonoBehaviour
{
    public Rigidbody m_affected;
    public float m_forceRatio = 1;
    public float m_maxDistance = 1.5f;
    public AnimationCurve m_forceByDistance;
    public Transform m_target;
    public ForceMode m_forceMode;
    void Update()
    {
        if (m_target == null) return;
        if (m_affected == null) return;
        Vector3 direction = m_target.position - m_affected.transform.position;
        float targetDistance = direction.magnitude;
        float powerPct = Mathf.Clamp(targetDistance / m_maxDistance,0f,1f);
        float animationCurvedForce = m_forceByDistance.Evaluate(powerPct);
        m_affected.AddForce(
            (direction) *(Time.deltaTime* m_forceRatio * animationCurvedForce),
            m_forceMode);
    }
}
