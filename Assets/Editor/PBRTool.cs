using UnityEditor;
using UnityEngine;

namespace Editor
{
    public class PBRTool
    {

        [MenuItem("Tools/ExportMesh")]
        static void ExportMesh()
        {
            var obj = Selection.activeObject;
            Debug.Log(obj.name);
            SkinnedMeshRenderer[] skms = (obj as GameObject).GetComponentsInChildren<SkinnedMeshRenderer>();
            for (int i = 0; i < skms.Length; i++)
            {
                Debug.Log(skms[i].name);
                var mesh = Object.Instantiate(skms[i].sharedMesh);
                AssetDatabase.CreateAsset(mesh, "Assets/Rendering/Art/Mesh/" + skms[i].name + ".asset");
            }
            AssetDatabase.Refresh();
            EditorUtility.DisplayDialog("tip", "export all mesh done", "ok");
        }

        [MenuItem("Assets/SetDirty")]
        static void SetAssetDirty()
        {
            var obj = Selection.activeObject;
            Debug.Log(obj.name);
            EditorUtility.SetDirty(obj);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

    }
}
