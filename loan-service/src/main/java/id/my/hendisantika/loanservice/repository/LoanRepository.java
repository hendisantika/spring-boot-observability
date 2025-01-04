package id.my.hendisantika.loanservice.repository;

import id.my.hendisantika.loanservice.entity.Loan;
import io.micrometer.observation.annotation.Observed;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.38
 * To change this template use File | Settings | File Templates.
 */
@Repository
@RequiredArgsConstructor
@Observed
public class LoanRepository {

    private final JdbcClient jdbcClient;

    @Transactional(readOnly = true)
    public List<Loan> findAll() {
        var findQuery = "SELECT id, loan_id, customer_name, customer_id, amount, loan_status FROM loans";
        return jdbcClient.sql(findQuery).query(Loan.class).list();
    }

    @Transactional
    public Long save(Loan loan) {
        var insertQuery = "INSERT INTO loans(loan_id, customer_name, customer_id, amount, loan_status) VALUES(?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcClient.sql(insertQuery)
                .param(1, UUID.randomUUID().toString())
                .param(2, loan.getCustomerName())
                .param(3, loan.getCustomerId())
                .param(4, loan.getAmount())
                .param(5, loan.getLoanStatus().toString())
                .update();
        return keyHolder.getKeyAs(Long.class);
    }
}
