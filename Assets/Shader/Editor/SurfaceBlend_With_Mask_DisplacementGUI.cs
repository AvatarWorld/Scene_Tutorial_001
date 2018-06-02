using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;
using System;

public class SurfaceBlend_With_Mask_DisplacementGUI : ShaderGUI
{
    private static class Styles
    {
        public static GUIContent albedo = new GUIContent("Albedo", "Albedo (RGB)");
        public static GUIContent specular = new GUIContent("Specular", "Specular (RGB) and Smoothness (A)");
        public static GUIContent normal = new GUIContent("Normal", "Normal Map");
        public static GUIContent displacement = new GUIContent("Displacement", "Displacement Map");
        public static GUIContent blendMask = new GUIContent("Mask", "Mask (Alpha) -> blend");
        public static GUIContent dispmapText = new GUIContent("Displacement", "Displacement (R)");
        public static GUIContent dispScaleText = new GUIContent("Disp Scale", "Displacement Scale");
        public static GUIContent dispOffsetText = new GUIContent("Disp Offset", "Displacement Offset");

        public static string material0Header = "Main Layer Maps";
        public static string material1Header = "Secondary Layer Maps";
        public static string maskHeader = "Blend : Mask";
        public static string displacementText = "Displacement Settings";
        public static GUIContent tessFacText = new GUIContent("Tessellation Factor", "Tessellation Factor Up Close");
        public static GUIContent tessMaxText = new GUIContent("Tess / Disp Fade Distance", "Tessellation & Displacement Max Distance");
    }

    MaterialProperty blendMask = null;
    MaterialProperty albedoMapLayer01 = null;
    MaterialProperty specularMapLayer01 = null;
    MaterialProperty smoothnessLayer01 = null;
    MaterialProperty normalMapLayer01 = null;
    MaterialProperty displacementMapLayer01 = null;

    MaterialProperty albedoMapLayer02 = null;
    MaterialProperty specularMapLayer02 = null;
    MaterialProperty smoothnessLayer02 = null;
    MaterialProperty normalMapLayer02 = null;
    MaterialProperty displacementMapLayer02 = null;

    MaterialProperty displacementValue = null;
    MaterialProperty dispoffset = null;
    MaterialProperty tessellation;
    MaterialProperty maxdist;

    const int kSecondLevelIndentOffset = 2;
    const float kVerticalSpacing = 2f;

    public void FindProperties(MaterialProperty[] props)
    {
        blendMask = FindProperty("_Mask", props);

        albedoMapLayer01 = FindProperty("_MainTexLayer01", props);
        specularMapLayer01 = FindProperty("_SpecGlossMapLayer01", props);
        smoothnessLayer01 = FindProperty("_SmoothnessLayer01", props);
        normalMapLayer01 = FindProperty("_NormapLayer01", props);
        displacementMapLayer01 = FindProperty("_DisplacementLayer01", props);

        albedoMapLayer02 = FindProperty("_MainTexLayer02", props);
        specularMapLayer02 = FindProperty("_SpecGlossMapLayer02", props);
        smoothnessLayer02 = FindProperty("_SmoothnessLayer02", props);
        normalMapLayer02 = FindProperty("_NormapLayer02", props);
        displacementMapLayer02 = FindProperty("_DisplacementLayer02", props);

        displacementValue = FindProperty("_Displacement", props);
        dispoffset = FindProperty("_DispOffset", props);

        tessellation = FindProperty("_Tess", props);
        maxdist = FindProperty("_maxDist", props, false);
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
            materialEditor.TexturePropertySingleLine(Styles.displacement, displacementMapLayer01);
            materialEditor.TextureScaleOffsetProperty(displacementMapLayer01);

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
            materialEditor.TexturePropertySingleLine(Styles.displacement, displacementMapLayer02);
            materialEditor.TextureScaleOffsetProperty(displacementMapLayer02);

            materialEditor.TexturePropertySingleLine(Styles.normal, normalMapLayer02);
            materialEditor.TextureScaleOffsetProperty(albedoMapLayer02);

            GUILayout.Label(Styles.displacementText, EditorStyles.boldLabel);
            materialEditor.ShaderProperty(displacementValue, Styles.dispScaleText.text);
            materialEditor.ShaderProperty(dispoffset, Styles.dispOffsetText.text);
            materialEditor.ShaderProperty(tessellation, Styles.tessFacText.text);
            materialEditor.ShaderProperty(maxdist, Styles.tessMaxText.text);
        }

        // Set dirty target mat
        if (EditorGUI.EndChangeCheck())
        {
            EditorUtility.SetDirty(targetMat);
        }
    }
}
