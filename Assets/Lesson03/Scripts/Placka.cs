using System.Collections.Generic;
using UnityEngine;

public class Placka : MonoBehaviour
{
    [SerializeField] private MeshFilter _mesh;
    
    void Start()
    {
        GenerateMesh(_mesh.mesh);
    }
	
    private void GenerateMesh(Mesh mesh)
    {
        List<Vector3> vertices = new();
        List<Vector3> normals  = new();
        List<int>     indices  = new();
        List<Vector2> uv       = new();

        const int VertexCount = 100;

        float fraction = 1f / (VertexCount - 1);
        for (int y = 0; y < VertexCount; y++)
        {
            for (int x = 0; x < VertexCount; x++)
            {
                vertices.Add(new Vector3(x / 10f, 0, y / 10f));
                normals.Add(new Vector3(0, 1,0));

                float uvX = x == 0 ? 0 : x == VertexCount - 1 ? 1 : fraction * x;
                float uvY = y == 0 ? 0 : y == VertexCount - 1 ? 1 : fraction * y;
                uv.Add(new Vector2(uvX, uvY));
            }
        }

        for (int i = 0; i < VertexCount - 1; i++)
        {
            for (int j = 0; j < VertexCount - 1; j++)
            {
                int thisRowStartIndex = j * VertexCount;
                int nextRowStartIndex = (j + 1) * VertexCount;
                indices.Add(thisRowStartIndex + i);
                indices.Add(nextRowStartIndex + i);
                indices.Add(thisRowStartIndex + i + 1);
                
                indices.Add(thisRowStartIndex + i + 1);
                indices.Add(nextRowStartIndex + i);
                indices.Add(nextRowStartIndex + i + 1);
            }
        }

        mesh.Clear();
        mesh.SetVertices(vertices);
        mesh.SetNormals(normals);
        mesh.SetUVs(0, uv);
        mesh.SetIndices(indices, MeshTopology.Triangles, 0);
    }
}