using UnityEngine;
using UnityEngine.SceneManagement;

public class Test : MonoBehaviour
{
    void Start()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    private void OnGUI()
    {
        GUI.Label(new Rect(10, 10, 200, 80), "pos:" + Input.mousePosition);
    }

    void OnSceneLoaded(Scene scence, LoadSceneMode mod)
    {
        Debug.Log("scene load");
    }
}
