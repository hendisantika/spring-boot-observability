package id.my.hendisantika.frauddetectionservice.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.28
 * To change this template use File | Settings | File Templates.
 */
@Repository
@RequiredArgsConstructor
public class FraudRecordRepository {

    private final JdbcClient jdbcClient;

    @Transactional(readOnly = true)
    public boolean existsByCustomerId(int customerId) {
        var sql = """
                SELECT COUNT(*) AS fraud__record_exists
                FROM fraud_records
                WHERE customer_id = :customerId;
                """;
        return jdbcClient.sql(sql)
                .param("customer_id", customerId)
                .query(Integer.class)
                .single() > 0;
    }
}
