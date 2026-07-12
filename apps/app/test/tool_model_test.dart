import 'package:bianjie_ai_app/shared/models/tool.dart';
import 'package:bianjie_ai_app/shared/models/tool_run.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tool parses structured config', () {
    final tool = Tool.fromJson({
      'id': 'pdf-convert',
      'name': 'PDF 转换',
      'description': '上传 PDF 后转换为 Word、图片或纯文本。',
      'categoryId': 'pdf',
      'tab': 'tools',
      'icon': 'pdf',
      'tags': ['PDF', '文件'],
      'route': '/tool/pdf-convert',
      'enabled': true,
      'sortOrder': 17,
      'requiresLogin': true,
      'requiresVip': false,
      'executionType': 'TASK',
      'config': {
        'inputModes': ['file'],
        'outputFormats': ['docx', 'png', 'txt'],
      },
    });

    expect(tool.id, 'pdf-convert');
    expect(tool.executionType, ToolExecutionType.task);
    expect(tool.config['outputFormats'], contains('docx'));
  });

  test('tool run parses submitted parameters', () {
    final run = ToolRun.fromJson({
      'id': 'run-001',
      'toolId': 'pdf-convert',
      'status': 'QUEUED',
      'input': 'convert file',
      'parameters': {'outputFormat': 'docx'},
      'output': {'summary': 'queued'},
      'createdAt': '2026-07-09T12:00:00Z',
      'updatedAt': '2026-07-09T12:00:00Z',
    });

    expect(run.parameters['outputFormat'], 'docx');
    expect(run.output['summary'], 'queued');
  });
}
