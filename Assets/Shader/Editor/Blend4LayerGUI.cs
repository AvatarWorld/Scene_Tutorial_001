using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;
using System;

public class Blend4LayerGUI : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent albedo = new GUIContent("Albedo", "Albedo (RGB)");
        public static GUIContent specular = new GUIContent("Specular", "R(Specular) G(Smoothness) B(Displacement)");
        public static GUIContent normal = new GUIContent("Normal", "Normal Map");
        public static GUIContent blendMask = new GUIContent("Mask", "Mask (Alpha) -> blend");
        public static GUIContent dispScaleText = new GUIContent("Disp Scale", "Displacement Scale");
        public static GUIContent dispOffsetText = new GUIContent("Disp Offset", "Displacement Offset");

        public static string materialMainHeader = "******Main Layer Maps";
        public static string material2Header = "******002 Layer Maps";
        public static string material3Header = "******003 Layer Maps";
        public static string material4Header = "******004 Layer Maps";

        public static string displacementText = "Displacement Settings";
        public static GUIContent tessFacText = new GUIContent("Tessellation Factor", "Tessellation Factor Up Close");
        public static GUIContent tessMaxText = new GUIContent("Tess / Disp Fade Distance", "Tessellation & Displacement Max Distance");
    }

    MaterialProperty albedoMapLayer01 = null;
    MaterialProperty specularMapLayer01 = null;
    MaterialProperty smoothnessLayer01 = null;
    MaterialProperty normalMapLayer01 = null;

    MaterialProperty albedoMapLayer02 = null;
    MaterialProperty specularMapLayer02 = null;
    MaterialProperty smoothnessLayer02 = null;
    MaterialProperty normalMapLayer02 = null;

    MaterialProperty albedoMapLayer03 = null;
    MaterialProperty specularMapLayer03 = null;
    MaterialProperty smoothnessLayer03 = null;
    MaterialProperty normalMapLayer03 = null;

    MaterialProperty albedoMapLayer04 = null;
    MaterialProperty specularMapLayer04 = null;
    MaterialProperty smoothnessLayer04 = null;
    MaterialProperty normalMapLayer04 = null;

    MaterialProperty displacementValue = null;
    MaterialProperty dispoffset = null;
    MaterialProperty tessellation;

    const int kSecondLevelIndentOffset = 2;
    const float kVerticalSpacing = 2f;

    public void FindProperties(MaterialProperty[] props)
    {

        albedoMapLayer01 = FindProperty("_MainTexLayer01", props);
        specularMapLayer01 = FindProperty("_SpecGlossMapLayer01", props);
        smoothnessLayer01 = FindProperty("_SmoothnessLayer01", props);
        normalMapLayer01 = FindProperty("_NormapLayer01", props);

        albedoMapLayer02 = FindProperty("_MainTexLayer02", props);
        specularMapLayer02 = FindProperty("_SpecGlossMapLayer02", props);
        smoothnessLayer02 = FindProperty("_SmoothnessLayer02", props);
        normalMapLayer02 = FindProperty("_NormapLayer02", props);

        albedoMapLayer03 = FindProperty("_MainTexLayer03", props);
        specularMapLayer03 = FindProperty("_SpecGlossMapLayer03", props);
        smoothnessLayer03 = FindProperty("_SmoothnessLayer03", props);
        normalMapLayer03 = FindProperty("_NormapLayer03", props);

        albedoMapLayer04 = FindProperty("_MainTexLayer04", props);
        specularMapLayer04 = FindProperty("_SpecGlossMapLayer04", props);
        smoothnessLayer04 = FindProperty("_SmoothnessLayer04", props);
        normalMapLayer04 = FindProperty("_NormapLayer04", props);

        displacementValue = FindProperty("_Displacement", props);
        dispoffset = FindProperty("_DispOffset", props);
        tessellation = FindProperty("_Tess", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        Material targetMat = materialEditor.target as Material;
        FindProperties(props);

        EditorGUIUtility.labelWidth = 120;

        EditorGUI.BeginChangeCheck();
        {
            GUILayout.Label(Styles.materialMainHeader, EditorStyles.boldLabel);

            // textures layer 01
            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapLayer01);
            materialEditor.TexturePropertySingleLine(Styles.specular, specularMapLayer01);
            materialEditor.ShaderProperty(smoothnessLayer01, "Smoothness");
            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer01);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer01);


            GUILayout.Label(Styles.material2Header, EditorStyles.boldLabel);

            // textures layer 02
            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapLayer02);
            materialEditor.TexturePropertySingleLine(Styles.specular, specularMapLayer02);
            materialEditor.ShaderProperty(smoothnessLayer02, "Smoothness");
            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer02);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer02);

            GUILayout.Label(Styles.material3Header, EditorStyles.boldLabel);

            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapLayer03);
            materialEditor.TexturePropertySingleLine(Styles.specular, specularMapLayer03);
            materialEditor.ShaderProperty(smoothnessLayer03, "Smoothness");
            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer03);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer03);

            GUILayout.Label(Styles.material4Header, EditorStyles.boldLabel);

            materialEditor.TexturePropertySingleLine(Styles.albedo, albedoMapLayer04);
            materialEditor.TexturePropertySingleLine(Styles.specular, specularMapLayer04);
            materialEditor.ShaderProperty(smoothnessLayer04, "Smoothness");
            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer04);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer04);

            GUILayout.Label(Styles.displacementText, EditorStyles.boldLabel);
            materialEditor.ShaderProperty(displacementValue, Styles.dispScaleText.text);
            materialEditor.ShaderProperty(dispoffset, Styles.dispOffsetText.text);
            materialEditor.ShaderProperty(tessellation, Styles.tessFacText.text);
        }

        // Set dirty target mat
        if (EditorGUI.EndChangeCheck())
        {
            EditorUtility.SetDirty(targetMat);
        }
    }
}
