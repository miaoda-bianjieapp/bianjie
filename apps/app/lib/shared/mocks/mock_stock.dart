import 'package:flutter/material.dart';

import '../models/stock_capability.dart';
import '../models/stock_stat.dart';

const mockStockStats = [
  StockStat(label: '分析报告已生成', value: '12.8', unit: '万份'),
  StockStat(label: '活跃用户', value: '6.4', unit: '万人'),
  StockStat(label: '为用户监控股票', value: '32.1', unit: '万只'),
];

const mockStockCapabilities = [
  StockCapability(
    id: 'analyze-stock',
    title: '分析个股',
    prompt: '分析个股的最新财报、估值和风险点',
    icon: Icons.query_stats,
    opensPage: false,
  ),
  StockCapability(
    id: 'backtest',
    title: '策略回测',
    prompt: '创建一个策略回测任务',
    icon: Icons.timeline,
    opensPage: true,
  ),
  StockCapability(
    id: 'market-overview',
    title: '市场概览',
    prompt: '总结今日市场结构和板块热度',
    icon: Icons.public,
    opensPage: true,
  ),
  StockCapability(
    id: 'stock-screener',
    title: '选股筛选',
    prompt: '按行业、估值和增长筛选股票',
    icon: Icons.filter_alt_outlined,
    opensPage: true,
  ),
  StockCapability(
    id: 'more',
    title: '更多',
    prompt: '查看更多股票能力',
    icon: Icons.more_horiz,
    opensPage: true,
  ),
];
