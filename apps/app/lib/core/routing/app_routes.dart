class AppRoutes {
  const AppRoutes._();

  static const home = '/home';
  static const tools = '/tools';
  static const stock = '/stock';
  static const agents = '/agents';
  static const writing = '/writing';
  static const profile = '/profile';
  static const history = '/history';
  static const models = '/models';
  static const membership = '/membership';

  static String tool(String toolId) => '/tool/$toolId';
  static String stockCapability(String capabilityId) => '/stock/$capabilityId';
  static String agentTemplate(String templateId) =>
      '/agents/template/$templateId';
  static String placeholder(String type) => '/placeholder/$type';
}
