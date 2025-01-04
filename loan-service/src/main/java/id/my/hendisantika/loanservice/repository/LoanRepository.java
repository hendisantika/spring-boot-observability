package id.my.hendisantika.loanservice.repository;

import id.my.hendisantika.loanservice.entity.Loan;
import io.micrometer.observation.annotation.Observed;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

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
        var findQuery = "SELECT id, loanid, customername, customerid, amount, loanstatus FROM loans";
        return jdbcClient.sql(findQuery).query(Loan.class).list();
    }
}
