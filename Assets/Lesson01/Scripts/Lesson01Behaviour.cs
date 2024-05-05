using System.Collections.Generic;
using UnityEngine;
using static Unity.Mathematics.math;

public class Lesson01Behaviour : MonoBehaviour
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

		const float torusRadius = 6f;
		const float radius = 3f;
		const int torusSegments = 30;
		const int sides = 6;

		float torusSegmentAngle = 2 * PI / torusSegments;
		float segmentAngle = 2 * PI / sides;
		
		float currentTorusAngle = 0f;

		var position = transform.position;
		for (int i = 0; i < torusSegments; i++)
		{
			var centerPos = position;
			float currentTorusCos = cos(currentTorusAngle);
			float currentTorusSin = sin(currentTorusAngle);
			
			centerPos.x += currentTorusCos * torusRadius;
			centerPos.z += currentTorusSin * torusRadius;
			float currentAngle = 0f;
			for (int j = 0; j < sides; j++)
			{
				var vertexPos = centerPos;
				float currentSegmentCos = cos(currentAngle);
				vertexPos.x += currentTorusCos * currentSegmentCos * radius;
				vertexPos.z += currentTorusSin * currentSegmentCos * radius;
				vertexPos.y += sin(currentAngle) * radius;
				
				vertices.Add(vertexPos);

				var normalVertex = (vertexPos - centerPos).normalized;
				normals.Add(normalVertex);

				currentAngle += segmentAngle;
			}

			currentTorusAngle += torusSegmentAngle;
		}

		int vertexCount = vertices.Count;
		for (int i = 0; i < torusSegments * sides; i++)
		{
			indices.Add((i + sides + 1) % vertexCount);
			indices.Add((i + sides) % vertexCount);
			indices.Add(i % vertexCount);

			indices.Add((i + 1) % vertexCount);
			indices.Add((i + sides + 1) % vertexCount);
			indices.Add(i % vertexCount);
		}

		// vertices.Add(new Vector3(-1, 0, -1));
		// vertices.Add(new Vector3(-1, 0,  1));
		// vertices.Add(new Vector3( 1, 0,  1));
		// vertices.Add(new Vector3( 1, 0, -1));
		//
		// normals.Add(new Vector3(0, 1, 0));
		// normals.Add(new Vector3(0, 1, 0));
		// normals.Add(new Vector3(0, 1, 0));
		// normals.Add(new Vector3(0, 1, 0));
		//
		// indices.Add(0);
		// indices.Add(1);
		// indices.Add(2);
		//
		// indices.Add(0);
		// indices.Add(2);
		// indices.Add(3);

		mesh.Clear();
		mesh.SetVertices(vertices);
		mesh.SetNormals(normals);
		mesh.SetIndices(indices, MeshTopology.Triangles, 0);
	}
}