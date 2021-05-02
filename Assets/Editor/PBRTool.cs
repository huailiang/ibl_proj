using UnityEditor;
using UnityEngine;
using System.IO;

namespace Editor
{
    public class PBRTool
    {
        [MenuItem("Tools/Github")]
        static void Go2Github()
        {
            Application.OpenURL("https://github.com/huailiang/ibl_proj");
        }
        
        
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
        
        [MenuItem("Tools/ExportCameraRT")]
        static void ExportSelectRT()
        {
            var rt = Camera.main.targetTexture;
            if (rt != null)
            {
                string folder = string.Empty;
                folder = EditorUtility.OpenFolderPanel("select output", folder, "Assets");
                RT2Png(folder, "lut", rt);
                AssetDatabase.Refresh();
            }
            else
                EditorUtility.DisplayDialog("tip", "select is not RT", "ok");
        }

        public static void RT2Png(string dir, string pngName, RenderTexture rt)
        {
            RenderTexture prev = RenderTexture.active;
            RenderTexture.active = rt;
            Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.RG16, false);
            png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            byte[] bytes = png.EncodeToPNG();
            if (!Directory.Exists(dir))
                Directory.CreateDirectory(dir);
            FileStream file = File.Open(dir + "/" + pngName + ".png", FileMode.Create);
            BinaryWriter writer = new BinaryWriter(file);
            writer.Write(bytes);
            file.Close();
            Texture.DestroyImmediate(png);
            RenderTexture.active = prev;
        }

    }
}
