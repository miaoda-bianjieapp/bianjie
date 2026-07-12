package com.bianjie.ai.api.modules.stock;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StockCapabilityRepository extends JpaRepository<StockCapabilityEntity, String> {

    List<StockCapabilityEntity> findAllByOrderBySortOrderAsc();
}

