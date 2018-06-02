using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;
using System;

public class SurfaceBlend_With_MaskGUI : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent albedo = new GUIContent("Albedo", "Albedo (RGB) Emissive (A)");
        public static GUIContent specular = new GUIContent("Specular", "Specular (RGB) and Smoothness (A)");
        public static GUIContent normal = new GUIContent("Normal", "Normal Map");
        public static GUIContent blendMask = new GUIContent("Mask", "Mask (A) -> blend");

        public static string material0Header = "Main Layer Maps";
        public static string material1Header = "Secondary Layer Maps";
        public static string maskHeader = "Blend : Mask";
    }

    MaterialProperty blendMask = null;
    MaterialProperty albedoMapLayer01 = null;
    MaterialProperty specularMapLayer01 = null;
    MaterialProperty smoothnessLayer01 = null;
    MaterialProperty normalMapLayer01 = null;

    MaterialProperty albedoMapLayer02 = null;
    MaterialProperty specularMapLayer02 = null;
    MaterialProperty smoothnessLayer02 = null;
    MaterialProperty normalMapLayer02 = null;

    const int kSecondLevelIndentOffset = 2;
    const float kVerticalSpacing = 2f;

    public void FindProperties(MaterialProperty[] props)
    {
        blendMask = FindProperty("_BlendMask", props);

        albedoMapLayer01 = FindProperty("_MainTexLayer01", props);
        specularMapLayer01 = FindProperty("_SpecGlossMapLayer01", props);
        smoothnessLayer01 = FindProperty("_SmoothnessLayer01", props);
        normalMapLayer01 = FindProperty("_NormapLayer01", props);

        albedoMapLayer02 = FindProperty("_MainTexLayer02", props);
        specularMapLayer02 = FindProperty("_SpecGlossMapLayer02", props);
        smoothnessLayer02 = FindProperty("_SmoothnessLayer02", props);
        normalMapLayer02 = FindProperty("_NormapLayer02", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        Material targetMat = materialEditor.target as Material;
        FindProperties(props);

        EditorGUIUtility.labelWidth = 120;

        EditorGUI.BeginChangeCheck();
        {
            GUILayout.Label(Styles.material0Header, EditorStyles.boldLabel);

            // textures layer 01
            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapLayer01);
            materialEditor.TexturePropertySingleLine(Styles.specular, specularMapLayer01);
            materialEditor.ShaderProperty(smoothnessLayer01, "Smoothness");

            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer01);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer01);


            GUILayout.Label(Styles.maskHeader, EditorStyles.boldLabel);

            materialEditor.TexturePropertySingleLine(Styles.blendMask, blendMask);
            materialEditor.TextureScaleOffsetProperty(blendMask);

            GUILayout.Label(Styles.material1Header, EditorStyles.boldLabel);

            // textures layer 02
            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapLayer02);
            materialEditor.TexturePropertySingleLine(Styles.specular, specularMapLayer02);
            materialEditor.ShaderProperty(smoothnessLayer02, "Smoothness");
            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer02);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer02);
        }

        // Set dirty target mat
        if (EditorGUI.EndChangeCheck())
        {
            EditorUtility.SetDirty(targetMat);
        }
    }
}
