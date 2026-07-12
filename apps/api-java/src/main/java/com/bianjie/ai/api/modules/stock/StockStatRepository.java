package com.bianjie.ai.api.modules.stock;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StockStatRepository extends JpaRepository<StockStatEntity, String> {

    List<StockStatEntity> findAllByOrderBySortOrderAsc();
}

