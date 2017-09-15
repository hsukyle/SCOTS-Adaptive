/*! \file Reach.hh
 *  Contains the Reach class. */

#ifndef REACH_HH_
#define REACH_HH_

#include "Adaptive.hh"

using namespace helper;

namespace scots {

/*! \class Reach
 *  \brief A class (derived from base Adaptive) that does adaptive multiscale abstraction-based synthesis for a reach specification.
 */
class Reach: public virtual Adaptive {
public:

    vector<SymbolicSet*> Gs_; /*!< Instance of *Xs_[i] containing goal states. */
    vector<SymbolicSet*> Is_; /*!< Instance of *Xs_[i] containing initial states. */
    vector<SymbolicSet*> validZs_; /*!< Contains winning states that act as savepoints. */
    vector<SymbolicSet*> validCs_; /*!< Controllers that act as savepoints. */
    vector<SymbolicSet*> finalCs_; /*!< Sequence of controllers that satisfy the specification. */
    vector<SymbolicSet*> finalZs_; /*!< Sequence of domains of finalCs_. */
    vector<SymbolicSet*> preYs_;

    int minToGoCoarser_;
    int minToBeValid_;
    int earlyBreak_;
    int verbose_;


    /*! Constructor for a Reach object. */
    Reach(char* logFile)
        : Adaptive(logFile)
    {
    }

    /*! Deconstructor for a Reach object. */
    ~Reach() {
        deleteVec(Gs_);
        deleteVec(Is_);
        deleteVec(validZs_);
        deleteVec(validCs_);
        deleteVec(finalCs_);
        deleteVec(finalZs_);
        deleteVec(preYs_);
    }

    /*! One iteration in an adaptive minimal fixed point.
        \param[in]		minToGoCoarser		Minimum number of iterations at an abstraction (not coarsest) before attemping to project to the next coarser abstraction.
        \param[in]		minToBeValid		Minimum number of iterations at an abstraction (not finest) after having gone coarser before a controller is declared valid and saved as a backup.
        \param[in]		earlyBreak			Whether the fixed point should end as soon as a strategy exists for the initial state.
        \param[in]		verbose				Whether messages detailing the steps of the algorithm should be printed to the log file.
        \param[in,out]	curAbs				0-index of the abstraction under consideration for the current iteration.
        \param[in,out]	iter				Counter for the total number of iterations of the minimal fixed point.
        \param[in,out]	justCoarsed			Status of the abstraction under consideration.
        \param[in,out]	iterCurAbs			Counter for the consecutive number of iterations for the current abstraction.
        \param[in,out]	reached				Whether the initial state has been declared winning.
        \param[in,out]	stop				Whether the fixed point should end.
    */
    void mu(int* curAbs, int* iter, int* justCoarsed, int* justStarted, int* iterCurAbs, int* reached, int* stop, int alwaysEventually = 0) {
        clog << "current abstraction: " << *curAbs << '\n';
        clog << "mu iteration: " << *iter << '\n';
        clog << "justCoarsed: " << *justCoarsed << '\n';
        clog << "iterCurAbs: " << *iterCurAbs << '\n';
        clog << "reached: " << *reached << '\n';
        clog << "controllers: " << finalCs_.size() << '\n';

        // get pre(Z)
        BDD preF = this->preC(this->Zs_[*curAbs]->symbolicSet_, this->Ts_[*curAbs]->symbolicSet_, *this->TTs_[*curAbs], *curAbs);
        // disjunct with goal (minimal fixed point)
        if (alwaysEventually) {
            preF |= (Gs_[*curAbs]->symbolicSet_ & preYs_[*curAbs]->symbolicSet_);
        }
        else {
            preF |= Gs_[*curAbs]->symbolicSet_;
        }
        // find new {(x,u)}
        BDD N = preF & (!(this->Cs_[*curAbs]->symbolicSet_.ExistAbstract(*this->cubeU_)));
        // add new {(x,u)} to C
        this->Cs_[*curAbs]->symbolicSet_ |= N;
        // project onto Xs_[*curAbs]
        this->Zs_[*curAbs]->symbolicSet_ = preF.ExistAbstract(*this->notXvars_[*curAbs]);

        if (((this->Zs_[*curAbs]->symbolicSet_ & Is_[*curAbs]->symbolicSet_) != this->ddmgr_->bddZero()) && (*reached == 0)) {
            *reached = 1;
            if (earlyBreak_ == 1) {
                saveCZ(*curAbs);
                *stop = 1;
                clog << "\nmu number of controllers: " << finalCs_.size() << '\n';
                return;
            }
        }

        if (*iter != 1) { // first iteration will always fail since we start with an empty Z
            if (N == this->ddmgr_->bddZero()) { // if iteration failed to yield new (x,u)
                if (*curAbs == *this->system_->numAbs_ - 1) { // if we're in the finest abstraction
                    saveCZ(*curAbs);
                    *stop = 1;
                    clog << "\nmu number of controllers: " << finalCs_.size() << '\n';
                }
                else {
                    if (verbose_) {
                        clog << "No new winning states; going finer.\n";
                    }
                    if (*justCoarsed == 1 || *justStarted == 1) { // current controller has not been declared valid
                        if (verbose_) {
                            clog << "Current controller has not been declared valid.\n";
                            clog << "Removing last elements of finalCs_ and finalZs_.\n";
                            clog << "Resetting Zs_[" << *curAbs << "] and Cs_[" << *curAbs << "] from valids.\n";
                        }

                        // remove the last saved C and F from finalCs_ and Fs_
                        if (finalCs_.size() > 0) {
                            SymbolicSet* C = finalCs_.back();
                            finalCs_.pop_back();
                            delete(C);
                            SymbolicSet* Z = finalZs_.back();
                            finalZs_.pop_back();
                            delete(Z);
                        }
                        *justCoarsed = 0;

                        // reset the current winning states and controller
                        this->Zs_[*curAbs]->symbolicSet_ = validZs_[*curAbs]->symbolicSet_;
                        this->Cs_[*curAbs]->symbolicSet_ = validCs_[*curAbs]->symbolicSet_;

                    }
                    else {
                        if (verbose_) {
                            clog << "Current controller has been declared valid.\n";
                            clog << "Saving Z and C of abstraction " << *curAbs << " into valids, finals.\n";
                            clog << "Finding inner approximation of Zs_[" << *curAbs << "] and copying into validZs_[" << *curAbs+1 << "].\n";
                        }
                        validZs_[*curAbs]->symbolicSet_ = this->Zs_[*curAbs]->symbolicSet_;
                        validCs_[*curAbs]->symbolicSet_ = this->Cs_[*curAbs]->symbolicSet_;

                        saveCZ(*curAbs);
                        this->finer(this->Zs_[*curAbs], this->Zs_[*curAbs+1], *curAbs);
                        validZs_[*curAbs+1]->symbolicSet_ = this->Zs_[*curAbs+1]->symbolicSet_;
                    }
                    *curAbs += 1;
                    *iterCurAbs = 1;
                }
            }
            else { // if there were new (x,u)
                if (*iterCurAbs >= minToBeValid_) {
                    if (*justCoarsed == 1) {
                        if (verbose_) {
                            clog << "Current controller now valid.\n";
                        }
                        *justCoarsed = 0;
                    }
                    if (*justStarted == 1) {
                        *justStarted = 0;
                        if (verbose_) {
                            clog << "First assignment of valid controller, justStarted = 0.\n";
                        }
                    }
                }
                if (*curAbs == 0) {
                    if (verbose_) {
                        clog << "More new states, already at coarsest gridding, continuing.\n";
                    }
                    *iterCurAbs += 1;
                }
                else {
                    if (*iterCurAbs >= minToGoCoarser_) {
                        if (verbose_) {
                            clog << "More new states, minToGoCoarser achieved; try going coarser.\n";
                        }
                        int more = this->coarser(this->Zs_[*curAbs-1], this->Zs_[*curAbs], *curAbs-1, 1);

                        if (more == 0) {
                            if (verbose_) {
                                clog << "Projecting to coarser gives no more states in coarser; not changing abstraction.\n";
                            }
                            *iterCurAbs += 1;
                        }
                        else {
                            if (verbose_) {
                                clog << "Projecting to coarser gives more states in coarser.\n";
                                clog << "Saving Z and C of abstraction " << *curAbs << " into validZs, validCs, finalZs, finalCs.\n";
                                clog << "Saving Z and C of abstraction " << *curAbs-1 << " into validZs_, validCs.\n";
                            }
                            if (*justStarted == 1) {
                                *justStarted = 0;
                                if (verbose_) {
                                    clog << "First projection to coarser abstraction, justStarted = 0.\n";
                                }
                            }
                            saveCZ(*curAbs);
                            validZs_[*curAbs]->symbolicSet_ = this->Zs_[*curAbs]->symbolicSet_;
                            validCs_[*curAbs]->symbolicSet_ = this->Cs_[*curAbs]->symbolicSet_;
                            *justCoarsed = 1;
                            validZs_[*curAbs-1]->symbolicSet_ = this->Zs_[*curAbs-1]->symbolicSet_;
                            validCs_[*curAbs-1]->symbolicSet_ = this->Cs_[*curAbs-1]->symbolicSet_;
                            *curAbs -= 1;
                            *iterCurAbs = 1;
                        }
                    }
                    else {
                        *iterCurAbs += 1;
                    }
                }
            }
        }
        else {
            if (verbose_) {
                clog << "First iteration, nothing happens.\n";
            }
        }

        clog << "\n";
        *iter += 1;
    }

    /*!	Writes, should they exist, a sequence of controller and controller domain BDDs to directories 'C' and 'Z' respectively that satisfy the reachability specification.
        \param[in]  startAbs            0-index of the abstraction to start with.
        \param[in]	minToGoCoarser		Minimum number of growing fixed point iterations needed before an attempt to go to a coarser abstraction.
        \param[in]	minToBeValid		Minimum number of growing fixed point iterations needed before a controller is declared valid.
        \param[in]  earlyBreak          If 1, the synthesis ends as soon as I meets the domain of C.
        \param[in]	verbose				If 1, prints additional information during synthesis to the log file.

        \return     1 if controller(s) satisfying specification is/are synthesized; 0 otherwise.
    */
    int reach(int startAbs, int minToGoCoarser, int minToBeValid, int earlyBreak, int verbose = 1) {
        if ( (startAbs < 0) || (startAbs >= *this->system_->numAbs_) ) {
            error("Error: startAbs out of range.\n");
        }

        minToGoCoarser_ = minToGoCoarser;
        minToBeValid_ = minToBeValid;
        earlyBreak_ = earlyBreak;
        verbose_ = verbose;

        TicToc tt;
        tt.tic();

        // removing obstacles from transition relation
        this->removeFromTs(&(this->Os_));

        clog << "Os_ removed from Ts_, TTs_.\n";


        int curAbs = startAbs;

        int iter = 1;
        int justCoarsed = 0;
        int justStarted = 1;
        int iterCurAbs = 1;
        int reached = 0;
        int stop = 0;

        while (1) {
            mu(&curAbs, &iter, &justCoarsed, &justStarted, &iterCurAbs, &reached, &stop);
            if (stop) {
                break;
            }
        }

        checkMakeDir("C");
        saveVec(finalCs_, "C/C");
        checkMakeDir("Z");
        saveVec(finalZs_, "Z/Z");
        clog << "----------------------------------------reach: ";
        tt.toc();

        if (reached) {
            cout << "Won.\n";
            clog << "Won.\n";
            return 1;
        }
        else {
            cout << "Lost.\n";
            clog << "Lost.\n";
            return 0;
        }
    }

    /*! Initializes objects specific to the following specifications: always-eventually, reach-while-avoid.
        \param[in]	addG	Function pointer specifying the points that should be added to the goal set.
        \param[in]	addI	Function pointer specifying the points that should be added to the initial set.
    */
    template<class G_type, class I_type>
    void initializeReach(G_type addG, I_type addI) {

        TicToc tt;
        tt.tic();
        this->initializeSpec(&Gs_, addG);
        clog << "Gs_ initialized.\n";
        this->initializeSpec(&Is_, addI);
        clog << "Is_ initialized.\n";
        clog << "------------------------------------------------initializeSpec on Gs_, Is_, Os_: ";
        tt.toc();

        // checking that specification is valid
        for (int i = 0; i < *this->system_->numAbs_; i++) {
            if ((Gs_[i]->symbolicSet_ & this->Os_[i]->symbolicSet_) != this->ddmgr_->bddZero()) {
                error("Error: G and O have nonzero intersection.\n");
            }
            if ((Is_[i]->symbolicSet_ & this->Os_[i]->symbolicSet_) != this->ddmgr_->bddZero()) {
                error("Error: I and O have nonzero intersection.\n");
            }
        }
        clog << "No obstacle problem with specification.\n";

        for (int i = 0; i < *this->system_->numAbs_; i++) {
            SymbolicSet* validZ = new SymbolicSet(*this->Xs_[i]);
            validZs_.push_back(validZ);
        }
        clog << "validZs_ initialized with empty domain.\n";

        for (int i = 0; i < *this->system_->numAbs_; i++) {
            SymbolicSet* validC = new SymbolicSet(*this->Xs_[i], *this->U_);
            validCs_.push_back(validC);
        }
        clog << "validCs_ initialized with empty domain.\n";

        for (int i = 0; i < *this->system_->numAbs_; i++) {
            SymbolicSet* preY = new SymbolicSet(*this->Xs_[i]);
            preY->addGridPoints();
            preYs_.push_back(preY);
        }
        clog << "preYs_ initialized with full domain.\n";

        saveVerify();
    }

    /*! Saves a snapshot of a controller and its domain into the sequence of final controllers and controller domains.
        \param[in] curAbs	0-index of the abstraction which the controller and controller domain that should be saved belong to.
    */
    void saveCZ(int curAbs) {
        SymbolicSet* C = new SymbolicSet(*this->Cs_[curAbs]);
        C->symbolicSet_ = this->Cs_[curAbs]->symbolicSet_;
        finalCs_.push_back(C);
        SymbolicSet* Z = new SymbolicSet(*this->Xs_[curAbs]);
        Z->symbolicSet_ = this->Zs_[curAbs]->symbolicSet_;
        finalZs_.push_back(Z);
    }

    /*! Saves and prints to log file some information related to the reachability/always-eventually specification. */
    void saveVerify() {
        printVec(Gs_, "G");
        printVec(Is_, "I");
        checkMakeDir("plotting");
        Gs_[*this->system_->numAbs_-1]->writeToFile("plotting/G.bdd");
        Is_[*this->system_->numAbs_-1]->writeToFile("plotting/I.bdd");
        checkMakeDir("G");
        saveVec(Gs_, "G/G");
    }
};

}

#endif /* REACH_HH_ */

